@isTest
private class ProductPricebookHandlerTest {
    
    static testMethod void testAfterInsert() {
        // Create test Standard Pricebook
  Id standardPricebook = Test.getStandardPricebookId();
        
        // Create test Custom Pricebook
        Pricebook2 customPricebook = new Pricebook2(
            Name = 'SriLankan Currency PB',
            IsActive = true
        );
        insert customPricebook;
        
        
        
          cgcloud__Product_Template__c templates = new cgcloud__Product_Template__c(
        	Name = 'Test Template',
            cgcloud__Sales_Org__c = '0001',
            cgcloud__Active__c = true,
            cgcloud__Description_Language_1__c = 'test Description'
        	);
        Insert templates;
        
   			product2 prod = new product2(
            name = 'test product',
            cgcloud__Product_Template__c = templates.Id,
            cgcloud__Product_Level__c = 'Product',
            cgcloud__Description_1_Language_1__c = 'tst Desc',
            cgcloud__Consumer_Goods_Product_Code__c = 'Test code',
            Product_Bundle__c = false
        );
        Insert prod;
        
        // Create an instance of the handler
        ProductPricebookHandler handler = new ProductPricebookHandler();
        
        Test.startTest();
        // Call the afterInsert method
        handler.afterInsert(new List<Product2>{prod});
        Test.stopTest();
        
        // Query PricebookEntry records for the test product
        List<PricebookEntry> standardEntries = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id AND Pricebook2Id = :standardPricebook];
        List<PricebookEntry> customEntries = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id AND Pricebook2Id = :customPricebook.Id];
        
        // Assert that PricebookEntry records are created
        System.assertNotEquals(0, standardEntries.size(), 'Standard PricebookEntry not created');
        System.assertNotEquals(0, customEntries.size(), 'Custom PricebookEntry not created');
    }
    
    static testMethod void testAfterUpdate() {
        // Create test product
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Product_Bundle__c = true,
            Bundle_Price__c = 1000
        );
        insert testProduct;
        
        // Create test OpportunityLineItem
        OpportunityLineItem testOLI = new OpportunityLineItem(
            Quantity = 1,
            UnitPrice = 1000,
            Product2Id = testProduct.Id,
            Final_Price__c = 900
        );
        insert testOLI;
        
        // Create an instance of the handler
        ProductPricebookHandler handler = new ProductPricebookHandler();
        
        // Create a map to simulate old product values
        Map<Id, Product2> oldProductsMap = new Map<Id, Product2>{
            testProduct.Id => new Product2(
                Bundle_Price__c = 800
            )
        };
        
        Test.startTest();
        // Call the afterUpdate method
        handler.afterUpdate(new List<Product2>{testProduct}, oldProductsMap);
        Test.stopTest();
        
        // Query OpportunityLineItem to check if Final_Price__c updated
        OpportunityLineItem oli = [SELECT Final_Price__c FROM OpportunityLineItem WHERE Product2Id = :testProduct.Id];
        
        // Assert that Final_Price__c is updated
        System.assertEquals(testProduct.Bundle_Price__c, oli.Final_Price__c, 'Final_Price__c not updated');
    }
}