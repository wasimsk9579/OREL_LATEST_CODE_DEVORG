@isTest
private class createRepeaterQuoteTest {
    @isTest
    static void testCreateRepeaterQuote() {
        
        
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
            Name = 'SriLankan Currency PB',
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
            // Add other required fields as needed
        );
        insert testAccount;
        
        // Create test Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Email = 'test@example.com',
            Phone = '1234567890'
            // Add other required fields as needed
        );
        insert testContact;
        
        // Create test Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            CloseDate = Date.today(),
            Amount = 1000,
            StageName ='Qualification',
            VAT_Percentage__c = 10,
            VAT__c = 'Include'
            // Add other required fields as needed
        );
        insert testOpportunity;
        
        // Create test OpportunityLineItem
        OpportunityLineItem testOLI = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            Product2Id = prod.Id,
             PricebookEntryId = customPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 1000,
            Final_Price__c = 900,
            AFP_Percent__c = 5,
            PFP_Percent__c = 10,
            TPC_Percent__c = 15,
            Electrical_Labour_Hours__c = 20,
            Transport_Charges__c = 30,
            Instalation_Charges__c = 40,
            Electrical_Labour__c = 50,
            Engraving_Tags_With_Legend_Plates_Hours__c = 80,
            Engraving_Tags_With_Legend_Plates__c = 90,
            Govt_Entity__c = 22
            // Add other required fields as needed
        );
        insert testOLI;
        
        Test.startTest();
        // Call the method being tested
        List<Id> createdQuoteIds = createRepeaterQuote.createStandardQuote(new List<Id>{testOpportunity.Id});
        Test.stopTest();
        
        // Verify that a Quote was created
        System.assertNotEquals(0, createdQuoteIds.size(), 'No Quote was created');
        
        // Add more assertions as needed to validate the behavior of the method
    }
}