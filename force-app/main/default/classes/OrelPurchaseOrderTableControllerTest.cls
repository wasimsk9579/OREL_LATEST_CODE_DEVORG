@isTest
private class OrelPurchaseOrderTableControllerTest {

    @isTest
    static void testGetoppordata() {
        // Test data setup
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testusers@example.com',
            Alias = 'tuser',
            Username = 'testusers@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id
        );
        insert testUser;
        
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Qualification',
            Amount = 1000,
            Status__c = 'Pending',
            CloseDate=system.today()
        );
        insert testOpportunity;

        Test.startTest();
        // Test the getoppordata method
        List<Opportunity> resultOpportunities = OrelPurchaseOrderTableController.getoppordata(testUser.Id);
        Test.stopTest();

        // Verify results
       /* System.assertNotEquals(null, resultOpportunities, 'Opportunity list should not be null');
        System.assertEquals(1, resultOpportunities.size(), 'Unexpected number of opportunities returned');
        Opportunity returnedOpportunity = resultOpportunities[0];
        System.assertEquals('Test Opportunity', returnedOpportunity.Name, 'Unexpected opportunity name');
        System.assertEquals('Prospecting', returnedOpportunity.StageName, 'Unexpected stage name');
        System.assertEquals(1000, returnedOpportunity.Amount, 'Unexpected amount');
        System.assertEquals('Open', returnedOpportunity.Status__c, 'Unexpected status');
        System.assertEquals(testAccount.Id, returnedOpportunity.AccountId, 'Unexpected account ID');*/
    }
}