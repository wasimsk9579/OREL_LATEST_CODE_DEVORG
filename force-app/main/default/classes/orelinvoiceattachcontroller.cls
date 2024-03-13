public class orelinvoiceattachcontroller {
     @Future(callout=true)
    public static void generatePDFAndSendEmail(Id invoiceId) {
       
                List<Orl_invoice__c> invoiceList = [SELECT Id, Name,Advanced_Order__c FROM Orl_invoice__c 
                                                    WHERE Id = :invoiceId LIMIT 1];
                Id Invid;
                if (invoiceList != null && !invoiceList.isEmpty()) {
                    Invid = invoiceList[0].Id;
                    system.debug('Invid' + Invid);
                } else {
                    System.debug('No Orl_invoice__c record found');
               
                }
                
                // Generate PDF and send email
                PageReference pdfPage = Page.InvoicePdfGenerator;
                pdfPage.getParameters().put('id', Invid);
                
                Blob pdfBlob;
                if (pdfPage != null) {
                    pdfBlob = pdfPage.getContentAsPDF();
                } else {
                    pdfBlob = Blob.valueOf('TEST');
                }
                
                // Attach PDF to the record
                Attachment attachment1 = new Attachment();
                attachment1.ParentId = Invid;
                attachment1.Name = 'Invoice.pdf';
                attachment1.Body = pdfBlob;
                attachment1.OwnerId = UserInfo.getUserId();
                try {
                    insert attachment1;
                    System.debug('Created Attachment: ' + attachment1);
                } catch (Exception e) {
                    // System.debug('Error inserting attachment1: ' + e.getMessage());
                    // Move to the next record if attachment insertion fails
                }
          
                
                // Send Email
                list<cgcloud__Order__c> salerep = [select id,Name,cgcloud__Responsible__c from cgcloud__Order__c Where id=:invoiceList[0].Advanced_Order__c limit 1];
                user us = [select id,Name,Email from User where id=:salerep[0].cgcloud__Responsible__c];
                system.debug('user'+us.Name);
                system.debug('email'+us.Email);
        
        
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject('Invoice Attached - OREL');
                email.setPlainTextBody('Thank you for your order. Please find the attached invoice PDF.');
                
                     String[] toAddresses = new String[]{us.Email};
                    email.setToAddresses(toAddresses);
                
                // Attach the PDF to the email
                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                emailAttachment.setFileName('Invoice.pdf');
                emailAttachment.setBody(pdfBlob);
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{emailAttachment});
                
                // Send the email
                try {
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                    System.debug('Email sent successfully.');
                } catch (Exception ex) {
                    System.debug('Error sending email: ' + ex.getMessage());
                  
                }
                
            }
        
    }