@isTest
private class OrlUpdateQuoteLineItemsControllerTest {
    
    @isTest
    static void testCreateOrderAndInvoice() {
        Id standardPricebook = Test.getStandardPricebookId();
         Product2 testProduct = new Product2(
                Name = 'Test Product',
                IsActive = true
            );
            insert testProduct;
        PricebookEntry standardPricebookEntry = new PricebookEntry(
                Pricebook2Id = standardPricebook,
                Product2Id = testProduct.Id,
                UnitPrice =500,
                 
                IsActive = true
            );
            insert standardPricebookEntry;
        // Create test data
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Qualification',Closedate=system.today());
        insert opp;
        
        Quote qt = new Quote(Name = 'Test Quote', OpportunityId = opp.Id, Status = 'Draft',Pricebook2Id = standardPricebook);
        insert qt;
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = qt.Id, Quantity = 5, Orl_Allocated_Quantity__c = 10,UnitPrice=200,Product2Id =testProduct.Id,PricebookEntryId=standardPricebookEntry.Id);
        insert qli;
        
        // Call the method to be tested
        Test.startTest();
        OrlUpdateQuoteLineItemsController.createOrderAndInvoice(new List<QuoteLineItem>{qli});
        OrlUpdateQuoteLineItemsController.getOppData(opp.Id);
        OrlUpdateQuoteLineItemsController.getbalancedata(opp.Id);


        Test.stopTest();
        
    }
}
    
/*
    
    @isTest
    static void testGetOppData() {
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1];
         Product2 testProduct = new Product2(
                Name = 'Test Product',
                IsActive = true
            );
            insert testProduct;
        PricebookEntry standardPricebookEntry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = testProduct.Id,
                UnitPrice =500,
                 
                IsActive = true
            );
            insert standardPricebookEntry;
        // Create test data
        Opportunity opp = new Opportunity(Name = 'Test Opp',StageName = 'Qualification',Closedate=system.today());
        insert opp;
        
        Quote qt = new Quote(Name = 'Test Quote', OpportunityId = opp.Id);
        insert qt;
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = qt.Id,UnitPrice=50,Product2Id = 'TestProduct');
        insert qli;
        
        // Call the method to be tested
        Test.startTest();
        List<QuoteLineItem> result = OrlUpdateQuoteLineItemsController.getOppData(opp.Id);
        Test.stopTest();
        
        // Verify the result
        System.assertNotEquals(0, result.size());
    }
    
 
    
    @isTest
    static void testGetbalancedata() {
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1];
         Product2 testProduct = new Product2(
                Name = 'Test Product',
                IsActive = true
            );
            insert testProduct;
        PricebookEntry standardPricebookEntry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = testProduct.Id,
                UnitPrice =500,
                 
                IsActive = true
            );
            insert standardPricebookEntry;
        // Create test data
        Opportunity opp = new Opportunity(Name = 'Test Opp',StageName = 'Qualification',Closedate=system.today());
        insert opp;
        
        Quote qt = new Quote(Name = 'Test Quote', OpportunityId = opp.Id);
        insert qt;
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = qt.Id, Product2Id = 'TestProduct');
        insert qli;
        
        // Call the method to be tested
        Test.startTest();
        List<cgcloud__Inventory__c> result = OrlUpdateQuoteLineItemsController.getbalancedata(opp.Id);
        Test.stopTest();
        
        // Verify the result
        System.assertNotEquals(0, result.size());
    }
    */