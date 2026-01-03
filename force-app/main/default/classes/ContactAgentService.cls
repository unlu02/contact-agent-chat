public with sharing class ContactAgentService {

    
    private static final String PREF_LANG_FIELD = 'Preferred_Language_c__c';

    public class AgentResult {
        public String reply;
        public Boolean didUpdate;
        public AgentResult(String reply, Boolean didUpdate) {
            this.reply = reply;
            this.didUpdate = didUpdate;
        }
    }

    public static AgentResult handle(Id contactId, String userMessage) {
        String msg = (userMessage == null) ? '' : userMessage.trim();
        if (contactId == null) {
            return new AgentResult('Missing Contact Id (recordId).', false);
        }
        if (String.isBlank(msg)) {
            return new AgentResult('Please type a message.', false);
        }

       
        Contact c = fetchContact(contactId);

        
        String lowerMsg = msg.toLowerCase();

        if (lowerMsg == '/summary') {
            return new AgentResult(buildSummary(c), false);
        }

        if (lowerMsg.startsWith('/update-lang')) {
            
            String[] parts = msg.split('\\s+');
            if (parts.size() < 2) {
                return new AgentResult('Usage: /update-lang tr', false);
            }

            String lang = parts[1].toLowerCase();
            if (lang != 'en' && lang != 'tr') {
                return new AgentResult('Only "en" or "tr" are supported. Example: /update-lang tr', false);
            }

            Boolean updated = updatePreferredLanguage(contactId, lang);
            if (updated) {
                return new AgentResult('Confirmed. Preferred Language has been updated to "' + lang + '".', true);
            }
            return new AgentResult('I could not update Preferred Language (missing permissions or field not accessible).', false);
        }

        
        if (lowerMsg.contains('email')) {
            String email = c.Email;
            if (String.isBlank(email)) {
                return new AgentResult('This contact does not have an email on record.', false);
            }
            return new AgentResult('This contact\'s email is: ' + email, false);
        }

        if (lowerMsg.contains('name')) {
            String name = ((c.FirstName == null ? '' : c.FirstName) + ' ' + (c.LastName == null ? '' : c.LastName)).trim();
            return new AgentResult('The contact name is: ' + (String.isBlank(name) ? '-' : name), false);
        }

        
        return new AgentResult(
            'Hi! I\'m Contact Helper. Ask about this contact (e.g., "What\'s this contact\'s email?") or use /summary or /update-lang tr.',
            false
        );
    }

    private static Contact fetchContact(Id contactId) {
        
        if (!Schema.sObjectType.Contact.isAccessible()) {
            throw new SecurityException('No access to Contact object.');
        }

        
        Set<String> desired = new Set<String>{ 'Id', 'FirstName', 'LastName', 'Email', PREF_LANG_FIELD };
        Map<String, Schema.SObjectField> fmap = Schema.SObjectType.Contact.fields.getMap();

        List<String> accessible = new List<String>();
        for (String f : desired) {
            if (f == 'Id') { accessible.add('Id'); continue; }
            if (fmap.containsKey(f) && fmap.get(f).getDescribe().isAccessible()) {
                accessible.add(f);
            }
        }

       
        if (accessible.isEmpty()) accessible.add('Id');

        String soql = 'SELECT ' + String.join(accessible, ',') +
                      ' FROM Contact WHERE Id = :contactId LIMIT 1';
        return (Contact)Database.query(soql);
    }

    private static String buildSummary(Contact c) {
        String name = ((c.FirstName == null ? '' : c.FirstName) + ' ' + (c.LastName == null ? '' : c.LastName)).trim();
        if (String.isBlank(name)) name = '-';

        String email = c.Email == null ? '-' : c.Email;

        String lang = (String)c.get(PREF_LANG_FIELD);
        if (String.isBlank(lang)) lang = '-';

        return 'Summary:\n' +
               '- Name: ' + name + '\n' +
               '- Email: ' + email + '\n' +
               '- Preferred Language: ' + lang;
    }

    private static Boolean updatePreferredLanguage(Id contactId, String lang) {
        
        if (!Schema.sObjectType.Contact.isUpdateable()) {
            return false;
        }

      
        Map<String, Schema.SObjectField> fmap = Schema.SObjectType.Contact.fields.getMap();
        if (!fmap.containsKey(PREF_LANG_FIELD)) return false;
        if (!fmap.get(PREF_LANG_FIELD).getDescribe().isUpdateable()) return false;

        Contact toUpdate = new Contact(Id = contactId);
        toUpdate.put(PREF_LANG_FIELD, lang);

        
        SObjectAccessDecision dec = Security.stripInaccessible(
            AccessType.UPDATABLE,
            new List<SObject>{ toUpdate }
        );
        List<SObject> safe = dec.getRecords();
        if (safe.isEmpty()) return false;

        update (Contact)safe[0];
        return true;
    }
}
