import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import sendMessage from '@salesforce/apex/ContactAgentChatController.sendMessage';

import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import PREF_LANG_FIELD from '@salesforce/schema/Contact.Preferred_Language_c__c';

const FIELDS = [FIRSTNAME_FIELD, LASTNAME_FIELD, EMAIL_FIELD, PREF_LANG_FIELD];

export default class ContactAgentChat extends LightningElement {
  @api recordId;

  agentName = 'Contact Helper';

  @track messages = [];
  @track inputText = '';
  @track isLoading = false;
  @track errorMessage = '';

  contact;

  @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
  wiredContact({ data, error }) {
    if (data) {
      this.contact = data;
      this.errorMessage = '';
    } else if (error) {
      this.contact = undefined;
      this.errorMessage = 'Contact bilgilerine erişemiyorum (FLS/CRUD olabilir).';
    }
  }

  get contactName() {
    const first = getFieldValue(this.contact, FIRSTNAME_FIELD) || '';
    const last = getFieldValue(this.contact, LASTNAME_FIELD) || '';
    return `${first} ${last}`.trim();
  }

  get contactEmail() {
    return getFieldValue(this.contact, EMAIL_FIELD) || '';
  }

  get contactPreferredLang() {
    return getFieldValue(this.contact, PREF_LANG_FIELD) || '';
  }

  handleInputChange(e) {
    this.inputText = e.target.value;
  }

  get isSendDisabled() {
    return this.isLoading || !this.inputText?.trim();
  }

  async handleSend() {
    const text = this.inputText.trim();
    if (!text || this.isLoading) return;

    this.errorMessage = '';
    this.appendMessage('user', text);
    this.inputText = '';

    this.isLoading = true;
    try {
      const res = await sendMessage({
        recordId: this.recordId,
        userMessage: text
      });

      if (res?.error) {
        this.errorMessage = res.error;
      } else {
        this.appendMessage('agent', res.reply || '(no reply)');
      }
    } catch (e) {
      this.errorMessage = 'Agent servisine ulaşılamadı.';
    } finally {
      this.isLoading = false;
      this.scrollToBottom();
    }
  }

  appendMessage(role, text) {
    this.messages = [
      ...this.messages,
      {
        id: String(Date.now()) + Math.random(),
        role,
        text,
        ts: new Date()
      }
    ];
    requestAnimationFrame(() => this.scrollToBottom());
  }

  get formattedMessages() {
    return this.messages.map((m) => ({
      ...m,
      time: new Date(m.ts).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      rowClass: m.role === 'user' ? 'row row-user' : 'row row-agent',
      bubbleClass: m.role === 'user' ? 'bubble bubble-user' : 'bubble bubble-agent'
    }));
  }

  scrollToBottom() {
    const el = this.template.querySelector('.transcript');
    if (el) el.scrollTop = el.scrollHeight;
  }
}
