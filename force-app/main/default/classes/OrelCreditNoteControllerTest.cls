@isTest
public class OrelCreditNoteControllerTest {
    @isTest
    static void testGetCredit() {
        // Create test user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standarduser6@testorg.com'
        );
        insert u;

        // Create test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create test Account Receivable
        cgcloud__Account_Receivable__c ar = new cgcloud__Account_Receivable__c(
            cgcloud__Amount__c = 100.00,
            cgcloud__Account__c = acc.Id
            // Add other required fields here
        );
        insert ar;

        Test.startTest();
        // Call the method to be tested
        List<cgcloud__Account_Receivable__c> result = orelcreditnotecontroller.getCredit(u.Id);
        Test.stopTest();

       
    }
}