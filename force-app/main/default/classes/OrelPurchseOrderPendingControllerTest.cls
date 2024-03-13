@isTest
private class OrelPurchseOrderPendingControllerTest {
    @isTest
    static void testGetOppo() {
        // Test data setup
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testusers2@example.com',
            Alias = 'tuser',
            Username = 'testusers2@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id
        );
        insert testUser;

        Opportunity testOpportunity1 = new Opportunity(
            Name = 'Test Opportunity 1',
            AccountId = testAccount.Id,
            StageName = 'Qualification',
            Amount = 1000,
            Status__c = 'Pending',
            CloseDate=system.today()
        );
        insert testOpportunity1;

        Opportunity testOpportunity2 = new Opportunity(
            Name = 'Test Opportunity 2',
            AccountId = testAccount.Id,
            StageName = 'Qualification',
            Amount = 2000,
            Status__c = 'Pending',
            CloseDate=system.today()
        );
        insert testOpportunity2;

        Test.startTest();
        // Test the getOppo method
        List<Opportunity> resultOpportunities = OrelPurchseOrderPendingController.getOppo(testUser.Id);
        Test.stopTest();
    }
}