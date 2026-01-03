# Contact Agent Chat

Bu proje, Salesforce İletişim Kaydı Sayfasına yerleştirilmiş bir Lightning Web Bileşeni (LWC) sohbet panelini göstermektedir.
Bu bileşen, kullanıcıların İletişim bilgilerini okuyabilen ve güncelleyebilen basit bir Apex tabanlı Agent ile etkileşim kurmasına olanak tanır.

---

## Proje Kurulumu

### Org ve Test Data
- Proje bir Salesforce Developer Org (Developer Edition) üzerinde geliştirilmiştir.
- Lightning Experience aktif olarak kullanılmıştır.
- Contact objesine `Preferred_Language_c__c` adlı özel bir picklist alanı eklenmiştir (`en`, `tr`).
- Test için Contact kayıtları oluşturulmuştur (ör. John Doe – john.doe@example.com – en).

---

### Bileşenin Contact Sayfasına Eklenmesi
- **Setup → Lightning App Builder** üzerinden bir **Contact Record Page** oluşturulmuş ve düzenlenmiştir.
- **contactAgentChat** Lightning Web Component’i sayfaya eklenmiştir.
- Sayfa kaydedilmiş ve **Org Default** olarak aktive edilmiştir.

---

### Agent’ın Çalışma Şekli
- LWC, Contact Record Page üzerinden otomatik olarak `recordId` alır.
- Contact verileri **Lightning Data Service** ile okunur.
- Kullanıcı mesajları Apex controller (`ContactAgentChatController`) üzerinden işlenir.
- Agent mantığı `ContactAgentService` sınıfında Apex ile uygulanır.

---

### Varsayımlar ve Sınırlamalar
- Bileşen yalnızca Contact Record Page’lerde kullanılmaktadır.
- Kullanıcının gerekli CRUD/FLS yetkilerine sahip olduğu varsayılmaktadır.
- Agent davranışı Apex tabanlıdır 

---

## Demo

1. Bir Contact kaydı açılır.
2. Chat panelinden:
   - *“What’s this contact’s email?”*
   - `/summary`
   - `/update-lang tr`
   komutları çalıştırılır.
3. Preferred Language alanının güncellendiği doğrulanır.

---

## Teknolojiler
- Salesforce Lightning Web Components (LWC)
- Apex 
- Lightning Data Service
- Salesforce CLI 

---
