global class CreateEmailActivity implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        try {
           
            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
            String htmlBody = email.htmlBody;
            String plainTextBody = stripHtmlTags(htmlBody); 
            String taskSubject = email.subject;
            
            String quoteNumber = taskSubject.substringAfter('Request:');
            quoteNumber = quoteNumber.trim();
            System.debug('quoteNumber op:' +quoteNumber);
            System.debug('htmlBody: ' + htmlBody);
            
            if (!String.isBlank(plainTextBody)) {
                // Assuming that the Quote record exists with the given QuoteNumber
                Quote quo = [SELECT Id, Name, QuoteNumber,Status, Customer_Response__c FROM Quote WHERE QuoteNumber = :quoteNumber LIMIT 1];
                
                if (quo != null) {
                    quo.Customer_Response__c = plainTextBody;
                    
                    System.debug('Updated Customer_Response__c: ' + quo.Customer_Response__c);
                    
                    if (htmlBody.containsIgnoreCase('Accepted')) {
                        quo.Status = 'Accepted';
                        update quo;
                        System.debug('updated status is---acp===:' +quo.Status);
                    }

                    else if (htmlBody.containsIgnoreCase('Denied')) {
                        quo.Status = 'Denied';
                        update quo;
                    } 
                }
            }
            
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            System.debug('Line Number: ' + e.getLineNumber());
        }
        return null;
    }
    
    private String stripHtmlTags(String input) {
        return input.replaceAll('<[^>]*>', '');
    }
}