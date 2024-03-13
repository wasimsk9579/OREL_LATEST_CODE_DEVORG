@isTest
public class OrelReturnInventoryControllertest {
    @isTest
    static void testGetInventory() {
        // Create test data
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User10',
            Email = 'testuse10@example.com',
            Username = 'testuse012@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
        );
        insert testUser;
        
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        cgcloud__Inventory_Control_Template__c testInventoryTemplate = new cgcloud__Inventory_Control_Template__c(
            Name = 'Test Inventory Template'
            // Add any necessary fields here
        );
        insert testInventoryTemplate;
        
        Id standardPricebook = Test.getStandardPricebookId();
         Product2 testProduct = new Product2(
                Name = 'Test Product',
                IsActive = true
            );
            insert testProduct;

            // Now create a PricebookEntry for the product in the standard price book
            PricebookEntry standardPricebookEntry = new PricebookEntry(
                Pricebook2Id = standardPricebook,
                Product2Id = testProduct.Id,
                UnitPrice =500,
                 
                IsActive = true
            );
            insert standardPricebookEntry;
        
        cgcloud__Inventory__c testInventory = new cgcloud__Inventory__c	(
           cgcloud__Account__c=testAccount.Id,
            cgcloud__Product__c=testProduct.Id,
            cgcloud__User__c=testUser.Id,
            cgcloud__Inventory_Template__c = testInventoryTemplate.Id,
            cgcloud__Phase__c='Active'
         
            // Add any necessary fields here
        );
        insert testInventory;
        
        // Call the method to test
        Test.startTest();
        List<cgcloud__Inventory__c> resultInventory = orelreturninventorycontroller.getInventory(testUser.Id);
        Test.stopTest();
        
    }
}