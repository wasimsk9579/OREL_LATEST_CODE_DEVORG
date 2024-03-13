@isTest
public class OrelApprovalProcessClassTest {

    @isTest
    static void testSubmitForApproval() {
        // Test data setup
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
   
        contact con = new contact();
        con.LastName='test';
        con.accountId =testAccount.Id;
        con.Email='test123@gmail.com';
        con.Is_primary_Contact__c=true;
        insert con;
           Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Distributor' LIMIT 1];   
 User testUser = new User(

            FirstName = 'Test',
            LastName = 'User',
            contactId = con.Id,
            Email = 'testusers@example.com',
            Alias = 'tuser',
            Username = 'testusers456@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = portalProfile.Id
        );
        insert testUser;
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Qualification',
            CloseDate = Date.today(),
            Amount = 10000
        );
        insert testOpp;
        Id standardPricebook = Test.getStandardPricebookId();
        // Test data setup
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



        OpportunityLineItem testLineItem = new OpportunityLineItem(
             OpportunityId = testOpp.Id,
                PricebookEntryId = standardPricebookEntry.Id, // Assign the standard price book entry to the opportunity line item
                Quantity = 5,
                UnitPrice = 100.00,
                Product2Id=testProduct.Id
        );
        insert testLineItem;

        // Call the method to be tested
        Test.startTest();
        String result = orelapprovalprocessclass.submitForApproval(testOpp.Id,'https://google.com');
        Test.stopTest();

        // Assertions
        System.assertEquals('success', result);

        // Additional assertions can be added based on the expected behavior of the method
    }

    @isTest
    static void testReturnOppId() {
        // Test data setup
        Opportunity testOpp = new Opportunity(Name = 'Test Opportunity',StageName = 'Qualification',CloseDate = Date.today());
        insert testOpp;

        // Call the method to be tested
        Test.startTest();
        String oppId = orelapprovalprocessclass.returnOppId(testOpp.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals(testOpp.Id, oppId);
    }

    @isTest
    static void testGetOppData() {
        // Test data setup
        Opportunity testOpp = new Opportunity(Name = 'Test Opportunity', StageName = 'Qualification',CloseDate = Date.today());
        insert testOpp;

        // Call the method to be tested
        Test.startTest();
        Opportunity oppData = orelapprovalprocessclass.getoppdata(testOpp.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals(testOpp.Id, oppData.Id);
        // Additional assertions can be added based on the expected behavior of the method
    }

    @isTest(seeAllData = true)
    static void testGetOppLineItemData() {
          Account comAccount = new Account(Name = 'Test Account1',Type__c='Company');
        insert comAccount;
        Id standardPricebook = Test.getStandardPricebookId();
        // Test data setup
        Product2 testProduct = new Product2(
                Name = 'Test Product',
                IsActive = true
            );
            insert testProduct;
cgcloud__Inventory_Control_Template__c invtem = new cgcloud__Inventory_Control_Template__c();
       
        insert invtem;
        
        cgcloud__Inventory__c proinv = new cgcloud__Inventory__c();
         proinv.cgcloud__Initial_Inventory__c=100;
        proinv.cgcloud__Account__c = comAccount.Id;
        proinv.cgcloud__Phase__c='active';
        proinv.cgcloud__Description_Language_1__c='ENGLISH';
        proinv.Orl_Inventory_type__c='Company Inventory';
        proinv.cgcloud__Inventory_Template__c = invtem.Id;
        proinv.cgcloud__Product__c=testProduct.Id;
         insert proinv;
            // Now create a PricebookEntry for the product in the standard price book
            PricebookEntry standardPricebookEntry = new PricebookEntry(
                Pricebook2Id = standardPricebook,
                Product2Id = testProduct.Id,
                UnitPrice =500,
                 
                IsActive = true
            );
            insert standardPricebookEntry;

            // Create a test opportunity
        Opportunity testOpp = new Opportunity(Name = 'Test Opportunity',StageName = 'Qualification',CloseDate = Date.today(),Pricebook2Id = standardPricebook);
        insert testOpp;

        OpportunityLineItem testLineItem = new OpportunityLineItem(
             OpportunityId = testOpp.Id,
                PricebookEntryId = standardPricebookEntry.Id, // Assign the standard price book entry to the opportunity line item
                Quantity = 5,
                UnitPrice = 100.00,
                Product2Id=testProduct.Id
        );
        insert testLineItem;

        // Call the method to be tested
        Test.startTest();
        List<OpportunityLineItem> lineItems = orelapprovalprocessclass.getopplineitemdata(testOpp.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals(1, lineItems.size());
        // Additional assertions can be added based on the expected behavior of the method
    }

    @isTest
    static void testApproveRecord() {
        // Test data setup
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Qualification',
            CloseDate = Date.today(),
            Status__c = 'Pending'
        );
        insert opp;

        // Call the method under test
        Test.startTest();
        orelapprovalprocessclass.approverecord(opp.Id);
        Test.stopTest();
    }

    @isTest
    static void testRejectRecord() {
        // Test data setup
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Qualification',
            CloseDate = Date.today(),
            Status__c = 'Pending'
        );
        insert opp;

        // Call the method under test
        Test.startTest();
        orelapprovalprocessclass.rejectrecord(opp.Id, 'Testing rejection');
        Test.stopTest();

        // Verify the results
    }
}