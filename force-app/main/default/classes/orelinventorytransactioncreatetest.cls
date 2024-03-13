@isTest
public class orelinventorytransactioncreatetest {
static testMethod void testSOInventoryController() {
        // Create Record Type for Opportunity
        Schema.SObjectType OpportunitySObjectType = Schema.getGlobalDescribe().get('Opportunity');
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = OpportunitySObjectType.getDescribe().getRecordTypeInfosByName();
        Id purchaseRecordTypeId = OpportunityRecordTypeInfo.get('Purchase').getRecordTypeId();

        // Create Test Accounts
        Account testAccount = new Account(Name='Test Account');
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
            cgcloud__Inventory_Template__c = testInventoryTemplate.Id,
            cgcloud__Phase__c='Active'
         
            // Add any necessary fields here
        );
        insert testInventory;

        // Create Test Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Qualification',
            CloseDate = Date.today(),
            RecordTypeId = purchaseRecordTypeId
        );
        insert testOpportunity;

        // Create Test Opportunity Line Items
        OpportunityLineItem testOpportunityLineItem1 = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            Product2Id = testInventory.cgcloud__Product__c,
            Quantity = 50,
            UnitPrice = 100
        );
        OpportunityLineItem testOpportunityLineItem2 = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            Product2Id = 'InvalidProduct',
            Quantity = 10,
            UnitPrice = 50
        );
        List<OpportunityLineItem> testOpportunityLineItems = new List<OpportunityLineItem>{
            testOpportunityLineItem1, testOpportunityLineItem2
        };
        insert testOpportunityLineItems;

        // Call the controller method
        Test.startTest();
        orelinventorytransactioncreate.SOInventoryController(testOpportunityLineItems);
        Test.stopTest();

        // Verify Errors
        for(OpportunityLineItem oli : testOpportunityLineItems) {
            if (oli.Product2Id != testInventory.cgcloud__Product__c) {
                System.assertEquals('Product doesnt consists of company inventory', 'Error message should match');
            } else {
                System.assertNotEquals('Product doesnt consists of company inventory','Error message should not match');
            }

            if (oli.Product2Id == 'InvalidProduct' || oli.Quantity > testInventory.cgcloud__Balance__c) {
                System.assertEquals('Quantity should not be greater than Company Inventory','Error message should match');
            } else {
                System.assertNotEquals('Quantity should not be greater than Company Inventory','Error message should not match');
            }
        }
    }

    static testMethod void testCreateInventoryTransaction() {
        // Create Record Type for Opportunity
        Schema.SObjectType OpportunitySObjectType = Schema.getGlobalDescribe().get('Opportunity');
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = OpportunitySObjectType.getDescribe().getRecordTypeInfosByName();
        Id purchaseRecordTypeId = OpportunityRecordTypeInfo.get('Purchase').getRecordTypeId();

        // Create Test Accounts
        Account testAccount = new Account(Name='Test Account', Type__c='Company');
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
            cgcloud__Inventory_Template__c = testInventoryTemplate.Id,
            cgcloud__Phase__c='Active'
         
            // Add any necessary fields here
        );
        insert testInventory;

        // Create Test Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            RecordTypeId = purchaseRecordTypeId
        );
        insert testOpportunity;

        // Create Test Opportunity Line Items
        OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            Product2Id = testInventory.cgcloud__Product__c,
            Quantity = 50,
            UnitPrice = 100
        );
        insert testOpportunityLineItem;

        List<OpportunityLineItem> testOpportunityLineItems = new List<OpportunityLineItem>{
            testOpportunityLineItem
        };

        // Call the controller method
        Test.startTest();
        orelinventorytransactioncreate.createInventoryTransaction(testOpportunityLineItems);
        Test.stopTest();

        // Verify Inventory Transactions
        List<cgcloud__Inventory_Transaction__c> invTransactions = [
            SELECT Id, cgcloud__Inventory__c, cgcloud__Amount__c
            FROM cgcloud__Inventory_Transaction__c
            WHERE cgcloud__Inventory__c = :testInventory.Id
        ];

        System.assertEquals(1, invTransactions.size());
        System.assertEquals(-50, invTransactions[0].cgcloud__Amount__c);
    }

}