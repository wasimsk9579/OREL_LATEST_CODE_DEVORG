@isTest
private class OrelPOtableproductdatacontrollerTest {
    @isTest(seeAllData = true)
    static void testGetopproduct() {
        // Query for the standard pricebook
        Id standardPricebook = Test.getStandardPricebookId();
       // Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1];
        //Pricebook2 standardPricebook = new Pricebook2(Name = 'Standard Price Book', IsActive = true);
        //insert standardPricebook;
        if (standardPricebook!= NULL) {
            // Standard price book exists, proceed with test setup
           // Pricebook2 standardPricebook = standardPricebooks[0];
            
            // Create a test product
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
            List<OpportunityLineItem> result = OrelPOtableproductdatacontroller.getopproduct(testOpportunity.Id);
            Test.stopTest();

            // Assertions
            System.assertNotEquals(null, result, 'Opportunity Line Item list should not be null');
            System.assertEquals(1, result.size(), 'Unexpected number of opportunity line items returned');
            OpportunityLineItem returnedOpportunityLineItem = result[0];
            System.assertEquals('Test Product', returnedOpportunityLineItem.Product2.Name, 'Unexpected product name');
            System.assertEquals(5, returnedOpportunityLineItem.Quantity, 'Unexpected quantity');
            System.assertEquals(100.00, returnedOpportunityLineItem.UnitPrice, 'Unexpected unit price');
        } else {
            // Standard price book doesn't exist, handle this scenario accordingly
            System.assert(false, 'Standard price book not found. Skipping test.');
        }
    }
}