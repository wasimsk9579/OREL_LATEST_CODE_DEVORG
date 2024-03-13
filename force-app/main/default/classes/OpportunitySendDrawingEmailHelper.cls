public class OpportunitySendDrawingEmailHelper {
    @AuraEnabled
    public static String sendDrawingsEmail(Id opportunitiesId) {
        String errorMessage = 'Please add attachments for the following opportunities:';
        
        try {
            System.debug('opportunitiesId-->' + opportunitiesId);
            List<Opportunity> opplist = [SELECT Id, Name, Orl_Opportunity_Number__c, RecordType.Name, Account.Name, AccountId, ContactId, 
                                         (SELECT Id, Name FROM Quotes), 
                                         (SELECT ContentDocumentId, ContentDocument.Title FROM ContentDocumentLinks) 
                                         FROM Opportunity 
                                         WHERE Id = :opportunitiesId AND StageName != 'Closed won' AND RecordType.Name = 'Repeater'];
            System.debug('query opp opplist====>' + opplist);

            if (opplist.isEmpty()) {
                // No opportunities found
                return 'No opportunities found with the specified criteria.';
            }

            for (Opportunity opp : opplist) {
                System.debug('Opportunity Id: ' + opp.Id);
                
                if (opp.ContentDocumentLinks.isEmpty()) {
                    system.debug('Attachments are empty for Opportunity Id: ' + opp.Id);
                    errorMessage += '\nOpportunity Id: ' + opp.Id;
                }
            }

            // Check if any opportunities have no attachments
            if (errorMessage != 'Please add attachments for the following opportunities:') {
                // Log the final error message
                System.debug('errorMessage is' +errorMessage);
                return errorMessage;
            }

            // Email sending logic
            for (Opportunity opp : opplist) {
                Account accList = [SELECT Id, Name, (SELECT Id, Email FROM Contacts) FROM Account WHERE Id = :opp.AccountId];
                
                List<String> toAddresses = new List<String>();
                
                if (accList.Contacts != null && !accList.Contacts.isEmpty()) {
                    for (Contact con : accList.Contacts) {
                        if (con.Email != null) {
                            toAddresses.add(con.Email);
                        }
                    }
                }
                
                String emailBody = 'Dear ' + opp.Account.Name + ',<br>';
                emailBody += '<br>';
                emailBody += 'I trust this message finds you well.<br>';
                emailBody += '<br>';
                emailBody += 'We are pleased to inform you that the drawing designs for Opportunity #' + opp.Orl_Opportunity_Number__c + ' are now available for your review. Attached to this email, you will find a comprehensive representation of the envisioned opportunity.<br>';
                emailBody += '<br>';
                emailBody += 'Your prompt attention to this matter is greatly appreciated. Should you have any feedback or require further clarification, please do not hesitate to respond to this email at your earliest convenience.<br>';
                emailBody += '<br>';
                emailBody += 'Thank you for your continued partnership.<br>';
                emailBody += '<br>';
                emailBody += 'Best Regards,<br>';
                emailBody += 'Sales Team';
                
                emailBody += '<br>';
                emailBody += 'Attachments:<br>';
                List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
                for (ContentDocumentLink docLink : opp.ContentDocumentLinks) {
                    List<ContentVersion> contentVersions = [SELECT  Id, Title, VersionData, FileType,FileExtension FROM ContentVersion WHERE ContentDocumentId = :docLink.ContentDocumentId LIMIT 1];
                    
                    for (ContentVersion cv : contentVersions) {
                        Blob fileBody = cv.VersionData;
                        if (fileBody != null && fileBody.size() > 0) {
                            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                            attachment.setFileName(cv.Title+'.'+cv.FileExtension);
                            attachment.setBody(fileBody);
                            
                            attachment.setContentType(cv.FileType);
                            String fileExtension = cv.Title.substringAfterLast('.');
                            if (fileExtension.equalsIgnoreCase('jpg') || fileExtension.equalsIgnoreCase('jpeg')) {
                                attachment.setContentType('image/jpeg');
                            } else if (fileExtension.equalsIgnoreCase('png')) {
                                attachment.setContentType('image/png');
                            } else if (fileExtension.equalsIgnoreCase('pdf')) {
                                attachment.setContentType('application/pdf');
                            } else {
                                // Add more conditions for other file types if necessary
                                attachment.setContentType('application/octet-stream');
                            }
                            System.debug('attachments---->'+ attachment);
                            fileAttachments.add(attachment);
                        }
                    }
                }
                
                // Set email properties
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>(toAddresses));
                List<String> ccAddresses = new List<String>{'senddrawingstocustomer@yourdomain.com'};
                email.setCcAddresses(ccAddresses);
                email.setSubject('Drawings for Opportunity: ' + opp.Orl_Opportunity_Number__c);
                email.setHtmlBody(emailBody);
                email.setFileAttachments(fileAttachments);
                
                // Send email using the Messaging.SingleEmailMessage class
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            }

        } catch(Exception e) {
            return 'An error occurred: ' + e.getMessage();
        } 

        return 'Emails sent successfully.';
    }
}