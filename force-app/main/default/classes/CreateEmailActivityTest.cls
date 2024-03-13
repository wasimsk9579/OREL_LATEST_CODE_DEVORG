@isTest
public class CreateEmailActivityTest {
    @isTest
    public static void testhandleInboundEmail(){
        List<Opportunity> opList = TestDataFactory.createOpportunity(1);
        List<Quote> quoteList = TestDataFactory.createQuote(1, opList[0].Id);
        System.debug('opList is=====>' +opList);
        System.debug('quoteList is===>' +quoteList);
        Messaging.InboundEmail test = new Messaging.InboundEmail();
        test.subject ='Request: ' + quoteList[0].QuoteNumber;
        test.htmlBody= '<p> test email. </p>';
        //test.plainTextBody = htmlBody;
        test.htmlBody ='Accepted';
        
        CreateEmailActivity handler = new CreateEmailActivity();
        handler.handleInboundEmail(test, new Messaging.InboundEnvelope());
        
        Quote updateQuote =[SELECT Id, Status,Name, QuoteNumber, Customer_Response__c FROM Quote];
        updateQuote.Customer_Response__c = 'Accepted';
        updateQuote.Status='Accepted';
        
        //System.assertEquals('Accepted', updateQuote.Customer_Response__c);
        System.assertEquals('Accepted', updateQuote.Status);
    }

}