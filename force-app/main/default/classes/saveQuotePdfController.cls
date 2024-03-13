public class saveQuotePdfController {

    private ApexPages.StandardController stdController;
    public String qutName {get; set;}
    @TestVisible private Id quoteId;
    public string  QuoId;
    public String MstrId {get; set;}
    public String PDFNo {get; set;}
    public blob b {get; set;}
    public Quote quote1 {get; set;} 
    public Boolean showSuccessMessage {get; set;}
    
    public saveQuotePdfController(ApexPages.StandardController controller) {
        MstrId = controller.getId();     
        system.debug('mstr id = ' +MstrId);
        Quote qt = [SELECT Id, Name, email FROM Quote WHERE Id = :MstrId];
        system.debug(' quote  = ' +qt);
        qutName = qt.Name;
        quote1 = qt; 
        System.debug('All info = '+quote1);
        QuoId = qt.Id;
        system.debug('quote id = ' +QuoId);
    }
    
    public PageReference pdfAction() {   
        try{
            
            
            PageReference pdfPage = new PageReference('/apex/QuotePDFPage?id=' + QuoId);
            if(Test.isRunningTest() == false){
                b = pdfPage.getContent();
                System.debug('bo: ' +b); 
            } else {
                b = Blob.valueOf('Test PDF Content');
            }
            
            // Check existing attachments for the quote
            Integer versionNumber = [SELECT count() FROM Attachment WHERE ParentId = :QuoId];
            
            // Increment the version number for the new attachment
            versionNumber++;
            
            // Create the attachment name with the incremented version number
            String attachmentName = 'Quote_V' + versionNumber;
            
            
            System.debug('body: ' +b);       
            
            Attachment attachment = new Attachment();
            attachment.Body = b;
            attachment.Name = attachmentName; 
            attachment.ContentType = 'application/pdf';
            attachment.ParentId = QuoId;
            insert attachment;
            System.debug('Attachment inserted: ' + attachment.body);
            
            Quote quote1 = [SELECT Id, Name, email,  QuoteNumber FROM Quote WHERE Id = :MstrId];
            
            
            String emailAddr = quote1.Email;
            
            
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            String emailAdd = quote1.Email;
            
            semail.setTargetObjectId(UserInfo.getUserId());
            semail.setwhatId(quote1.id);
            semail.setSaveAsActivity(false);
            semail.setUseSignature(false);
            semail.setToAddresses(new List<String>{emailAdd});
            // Set the CC recipients
        System.debug('to address from apex cls===>' +emailAdd);
        semail.setCcAddresses(new String[]{'emailquotestatus@9-2yqi23dyxk0ktpbdngpm2ibckdlvcvtk2efcjm860b86u8amyd.1m-mtieae.cs117.apex.sandbox.salesforce.com'});
        
	//	String[] sendingTocAdd = new String[]{'EmailService unique code'};
	//	semail.setCcAddresses(sendingTocAdd);
		semail.setSubject('Quote Approval Request: '+quote1.QuoteNumber);
		semail.setHTMLBody('Dear Customer,<br>This is to inform you that a new Quote ' + quote1.QuoteNumber + ' has been created, as per your requirement.<br> Please verify the Quote and respond accordingly.<br> Thanks,<br>Sales Team.');
 List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            allmsg.add(semail);
            
            Messaging.EmailFileAttachment attachmentFile = new Messaging.EmailFileAttachment();
            attachmentFile.setFileName(+quote1.Name  + '.pdf');
            attachmentFile.setBody(b);
            attachmentFile.setContentType('application/pdf');
            semail.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachmentFile});
            
            //      // Send the email message
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{semail});
            
            // Add success message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email sent successfully!'));
            
            // Redirect to the current record page
            PageReference recordPage = new ApexPages.StandardController(quote1).view();
            recordPage.setRedirect(true);
            
            
            return recordPage; 
        } catch (Exception e){
            System.debug('error message--> '+e.getMessage());
            return null;
        }      
    }
    
    
    public PageReference cancel() {
        PageReference pdf = new PageReference('/' + MstrId);
        pdf.setRedirect(true);
        return pdf;
    }
}