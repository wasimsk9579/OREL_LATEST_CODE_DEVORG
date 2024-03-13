public class SendDrawingtoProductionTeamHelper {
    @AuraEnabled
    public static void updateStatus() {
        system.debug('email method exicuting ');
        List<Opportunity> opList = [SELECT Id, Name, StageName, recordtype.name, Account.Name, Account.Email__c, Account.Phone FROM Opportunity WHERE StageName='Closed won' LIMIT 1];
                System.debug('oplist query op----->' + opList);
        if (opList != null && !opList.isEmpty()) {
            Opportunity opdata = opList[0];
            System.debug('opdata rec type====>' + opdata.recordtype.name);
            Set<Id> oppId = new Set<Id>();
            oppId.add(opdata.Id);
            system.debug('opdata data===>' + opdata);
            
            // Declare emailBody here so that it is in scope throughout the method
            String emailBody = '';
            
            if (opdata.StageName == 'Closed Won' && opdata.RecordType.name == 'Repeater') {
                List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :oppId];
                System.debug('contentDocumentLinks--->'+contentDocumentLinks.size());
                Set<Id> contentVersionIds = new Set<Id>();
                
                for (ContentDocumentLink cdl : contentDocumentLinks) {
                    contentVersionIds.add(cdl.ContentDocumentId);
                }
                System.debug('contentVersionIds--->'+contentVersionIds);
                List<ContentVersion> contentVersions = [SELECT Id, Title, VersionData, FileType,FileExtension FROM ContentVersion WHERE ContentDocumentId IN :contentVersionIds];
                System.debug('contentVersions--->'+contentVersions);
                emailBody = 'Dear Production Team,\n' +
                    'I trust this message finds you well. I would like to inform you that the opportunity has been closed.\n' +
                    'Attached are the details of the products involved, along with corresponding drawings.\n\n' +
                    '\n' +
                    'Related opportunity: ' + opdata.Name + '\n' +
                    'Customer Name: ' + opdata.Account.Name + '\n' +
                    'Customer Phone Number: ' + opdata.Account.Phone + '\n' +
                    'Customer Email: ' + opdata.Account.Email__c + '\n' +
                    'Thanks & Regards \n' +
                    'OREL';
                
                List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
                
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
                        
                        fileAttachments.add(attachment);
                    }
                }
                system.debug('fileAttachments--->'+ fileAttachments.size());
                
                // Declare the email message
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                semail.setSubject('An opportunity has been closed.');
                semail.setToAddresses(new String[] { 'pratikshaagresfdc@gmail.com' });
                
                // Add attachments to the email
                semail.setFileAttachments(fileAttachments);
                
                // Set the email body
                semail.setPlainTextBody(emailBody);
                
                // Send the email message
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { semail });
            }
        }
    }
}