@isTest
public class OrlDistributorCreatePOControllerTest {
    @isTest
    static void testGetProductsForDistributor() {
        // Create test data
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuser5321@example.com',
            Email = 'testuser6563@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
        );
        insert testUser;
        ProductCatalog testcatalog = new ProductCatalog(
            Name='test catalog'
        );
          // Create ProductCategory
        ProductCategory testCategory = new ProductCategory(
            Name = 'Test Category',
            CatalogId=testcatalog.Id
        );
        insert testCategory;

         Id standardPricebook = Test.getStandardPricebookId();
         Product2 testProduct = new Product2(
                Name = 'Test Product',
                IsActive = true,
             cgcloud__Criterion_1_Product__c=testCategory.Id
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

            // Create a test opportunity
            Opportunity testOpportunity = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Qualification',
                CloseDate = Date.today(),
                Pricebook2Id = standardPricebook // Assign the standard price book to the opportunity
            );
            insert testOpportunity;

            // Create a test opportunity line item
            OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                PricebookEntryId = standardPricebookEntry.Id, // Assign the standard price book entry to the opportunity line item
                Quantity = 5,
                UnitPrice = 100.00
            );
            insert testOpportunityLineItem;

        // Call the method
        Test.startTest();
        List<Product2> products = OrlDistributorCreatePOController.getProductsForDistributor(testUser.Id);
        // String result = OrlDistributorCreatePOController.createPurchaseOrder(testUser.Id, testOpportunityLineItem.Id);
        // String resultt = OrlDistributorCreatePOController.createOppAndOppLineItems(testUser.Id, testOpportunityLineItem.Id);
        Test.stopTest();

    }

}