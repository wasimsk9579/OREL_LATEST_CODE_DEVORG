@isTest
private class GetProductOfReturnOrderTest {
 @isTest(seeAllData = true)
    public static void testGetProductInfor() {
        // Create test data
         cgcloud__Order_Template__c testOrderTemplate = new cgcloud__Order_Template__c();
        insert testOrderTemplate;
        Account testaccount = new Account(
            Name='Test Account',
        Type__c = 'Company');
        insert testaccount;
        cgcloud__Order__c testOrder = new cgcloud__Order__c(
          cgcloud__Order_Template__c = testOrderTemplate.Id);
        insert testOrder;

         Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1];
        
 Product2 testProduct = new Product2(
                Name = 'Test Product',
                IsActive = true
            );
            insert testProduct;

            // Now create a PricebookEntry for the product in the standard price book
            PricebookEntry standardPricebookEntry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = testProduct.Id,
                UnitPrice =500,
                 
                IsActive = true
            );
            insert standardPricebookEntry;


        cgcloud__Order_Item__c testOrderItem = new cgcloud__Order_Item__c(
            cgcloud__Order__c = testOrder.Id,
            cgcloud__Product__c = testProduct.Id,
            cgcloud__Quantity__c = 1
        );
        insert testOrderItem;

        Test.startTest();
        // Call the method under test
        List<cgcloud__Order_Item__c> result = GetProductOfReturnOrder.getProductInfor(testOrder.Id);
        Test.stopTest();
    }
}