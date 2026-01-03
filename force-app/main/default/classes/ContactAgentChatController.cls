public with sharing class ContactAgentChatController {

    public class ChatResponse {
        @AuraEnabled public String agentName;
        @AuraEnabled public String reply;
        @AuraEnabled public Boolean didUpdate;
        @AuraEnabled public String error;
    }

    @AuraEnabled(cacheable=false)
    public static ChatResponse sendMessage(Id recordId, String userMessage) {
        ChatResponse res = new ChatResponse();
        res.agentName = 'Contact Helper';
        res.didUpdate = false;
        res.reply = '';
        res.error = null;

        try {
            if (recordId == null) {
                res.error = 'recordId is required.';
                return res;
            }

            if (String.isBlank(userMessage)) {
                res.error = 'userMessage is required.';
                return res;
            }

            ContactAgentService.AgentResult r =
                ContactAgentService.handle(recordId, userMessage);

            res.reply = r.reply;
            res.didUpdate = r.didUpdate;
            return res;

        } catch (SecurityException se) {
            res.error = 'Access denied.';
            return res;

        } catch (Exception e) {
            res.error = 'Agent error: ' + e.getMessage();
            return res;
        }
    }
}
