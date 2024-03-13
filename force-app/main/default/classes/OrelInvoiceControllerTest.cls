@isTest
public class OrelInvoiceControllerTest {
    @isTest
    static void testGetInvoice() {
        Account acc = new Account(
        Name='Test Account');
        insert acc;
            
        cgcloud__Order_Template__c ordertemplate = new cgcloud__Order_Template__c(
            Name='Test Template'
        );
        insert ordertemplate;
        // Create test Advanced Order
        cgcloud__Order__c order = new cgcloud__Order__c(
         cgcloud__Order_Template__c= ordertemplate.Id,
            cgcloud__Order_Account__c=acc.Id
        
        );
        insert order;

        // Create test Invoice
        Orl_invoice__c invoice = new Orl_invoice__c(
            Name = 'Test Invoice',
            Advanced_Order__c = order.Id
          
            // Add other required fields here
        );
        insert invoice;

        Test.startTest();
        // Call the method to be tested
        List<Orl_invoice__c> result = orelinvoicecontroller.getinvoice(order.Id);
        Test.stopTest();

        // Assert the results
        System.assertEquals(1, result.size(), 'Expected a single Invoice record');
        System.assertEquals('Test Invoice', result[0].Name, 'Name of the Invoice record does not match');
        // Add additional assertions for other fields if needed
    }
}