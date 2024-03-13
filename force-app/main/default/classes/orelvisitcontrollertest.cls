@isTest
public class orelvisitcontrollertest {

    @isTest
    static void testGetVisit() {
        // Create test data
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser013@example.com',
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
        
        RetailStore testretail = new RetailStore(
            AccountId=testAccount.Id,
            Name='test retail'
        );
        insert testretail;
        
        Visit testVisit = new Visit(
            PlannedVisitStartTime = Datetime.now(),
            PlannedVisitEndTime = Datetime.now().addHours(1),
            AccountId = testAccount.Id,
            PlaceId=testretail.Id
        );
        insert testVisit;
        
        // Call the method to test
        Test.startTest();
        List<Visit> resultVisit = orelvisitcontroller.getvisit(testUser.Id);
        Test.stopTest();
        
    
    }
}