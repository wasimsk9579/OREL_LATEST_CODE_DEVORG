@isTest
private class createRunnerQuoteTest {
    @isTest
    static void testCreateRunnerQuote() {
        
        
          cgcloud__Product_Template__c templates = new cgcloud__Product_Template__c(
        	Name = 'Test Template',
            cgcloud__Sales_Org__c = '0001',
            cgcloud__Active__c = true,
            cgcloud__Description_Language_1__c = 'test Description'
        	);
        Insert templates;
        
  
   //     Pricebook2 standardPricebook;

//    standardPricebook = [SELECT Id, Name FROM Pricebook2 WHERE isStandard = true];

   Id standardPricebook = Test.getStandardPricebookId();
        
           
        product2 prod = new product2(
            name = 'test product',
            cgcloud__Product_Template__c = templates.Id,
            cgcloud__Product_Level__c = 'Product',
            cgcloud__Description_1_Language_1__c = 'tst Desc',
            cgcloud__Consumer_Goods_Product_Code__c = 'Test code',
            Product_Bundle__c = false
        );
        Insert prod;

        // Create PricebookEntry linking the Product to the Standard Pricebook
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook,
            Product2Id = prod.Id,
            UnitPrice = 1000.00,
            IsActive = true
        );
        insert testPricebookEntry;

        // Create Custom Pricebook
        Pricebook2 customPricebook = new Pricebook2(
            Name = 'Runner Pricebook',
            IsActive = true
        );
        insert customPricebook;

        // Create PricebookEntry linking the Product to the Custom Pricebook
        PricebookEntry customPricebookEntry = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            Product2Id = prod.Id,
            UnitPrice = 1200.00,
            IsActive = true
        );
        insert customPricebookEntry;

        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        // Create test Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Email = 'test@example.com',
            Phone = '1234567890'
        );
        insert testContact;

        // Create test Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            CloseDate = Date.today(),
            Amount = 1200,
            VAT_Percentage__c = 10,
            VAT__c = 'Include',
            StageName = 'Qualification'
        );
        insert testOpportunity;

        // Create test OpportunityLineItem
        OpportunityLineItem testOLI = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            Product2Id = prod.Id,
            PricebookEntryId = customPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 1200,
            Final_Price__c = 900
        );
        insert testOLI;

        Test.startTest();
        // Call the method being tested
        List<Id> createdQuoteIds = createRunnerQuote.createRunnerQuote(new List<Id>{testOpportunity.Id});
        Test.stopTest();
        
    }
}