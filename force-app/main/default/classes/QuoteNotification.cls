public class QuoteNotification {
    public static void sendApproveNotification(List<Quote> quoteData, Map<Id, Quote> oldQuoteMap){
        for(Quote newqt: quoteData){
            Quote oldqt = oldQuoteMap.get(newqt.Id);
            if(newqt.Orl_Approval_Status__c != oldqt.Orl_Approval_Status__c && newqt.Orl_Approval_Status__c=='Approved'){
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                CustomNotificationType cNotify = [SELECT Id FROM CustomNotificationType WHERE developerName = 'Quote_Approval_Notification_to_Project_team' LIMIT 1];
                notification.setNotificationTypeId(cNotify.Id);
                notification.setBody('Your quote  ' + newqt.Name + ' has been approved.');
                notification.setTitle('A quote is approved');
                notification.setTargetId(newqt.Id);
                
                Set<String> recipientIds = new Set<String>{newqt.OwnerId};
                    notification.send(recipientIds);   
            }
        }
    }   
    
    public static void sendRejectNotification(List<Quote> quoteData, Map<Id, Quote> oldQuoteMap){
        for(Quote newqt: quoteData){
            Quote oldqt = oldQuoteMap.get(newqt.Id);
            if(newqt.Orl_Approval_Status__c != oldqt.Orl_Approval_Status__c && newqt.Orl_Approval_Status__c=='Rejected'){
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                CustomNotificationType cNotify = [SELECT Id FROM CustomNotificationType WHERE developerName = 'Quote_Rejection_Notification_to_Project_team' LIMIT 1];
                notification.setNotificationTypeId(cNotify.Id);
                notification.setBody('Your quote  ' + newqt.Name + ' has been rejected.');
                notification.setTitle('A quote is rejected');
                notification.setTargetId(newqt.Id);
                
                Set<String> recipientIds = new Set<String>{newqt.OwnerId};
                    notification.send(recipientIds);   
            }
        }
    }
    
    public static void sendAcceptanceEmail(List<Quote> newQuote , Map<Id, Quote> oldMap){
        //Id<Quote> quoteId = new Id<Quote>(); 
        for(Quote qt: newQuote) {
            Quote oldQuote =oldMap.get(qt.Id);
          
            Id initialQuoteOwner = qt.CreatedById;
            List<String> toAddress = new List<String>();
            toAddress.add(initialQuoteOwner);
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            
            if(qt.Status=='Accepted' && oldQuote.Status!='Accepted' && qt.Orl_Opportunity_record_type__c=='Repeater'){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSaveAsActivity(false);
                email.setToAddresses(toAddress);
                email.setTargetObjectId(UserInfo.getUserId());
                //email.setSubject('Quote'+ qt.Name +'has been Accepted by customer');
                EmailTemplate template =[Select id, name from EmailTemplate where name='Quote acceptance notification to project team'];
                email.setTemplateId(template.Id);
                emailList.add(email);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            }
        }
    }
    
    public static void sendRejectionEmail(List<Quote> newQuote, Map<Id, Quote> oldMap){
        //Id<Quote> quoteId = new Id<Quote>(); 
        for(Quote qt: newQuote) {
            Quote oldQuote = oldMap.get(qt.Id);
            Id initialQuoteOwner = qt.CreatedById;
            List<String> toAddress = new List<String>();
            toAddress.add(initialQuoteOwner);
            
            
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            
            if(qt.Status=='Denied' && oldQuote.Status!='Denied' && qt.Orl_Opportunity_record_type__c=='Repeater'){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSaveAsActivity(false);
                email.setToAddresses(toAddress);
                email.setTargetObjectId(UserInfo.getUserId());
                //email.setSubject('Quote'+ qt.Name +'has been Accepted by customer');
                EmailTemplate tmp =[Select id, name from EmailTemplate where name ='Quote has been rejected by customer'];
                email.setTemplateId(tmp.Id);
                emailList.add(email);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            }
        }
    }
}