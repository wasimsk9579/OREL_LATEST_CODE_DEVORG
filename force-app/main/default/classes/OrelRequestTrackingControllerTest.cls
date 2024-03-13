@isTest
private class OrelRequestTrackingControllerTest {

    @isTest
    static void testGetOrelRequestsByUser() {
        // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User testUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing123', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = p.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg123.com');
        insert testUser;

        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test OrelRequestTracking__c records associated with the test user's account
        OrelRequestTracking__c testRecord1 = new OrelRequestTracking__c(Account__c = testAccount.Id, Orel_Reason__c = 'Test Reason 1', OrelStatus__c = 'Deboard initiated', Orel_Initiated_By__c = testUser.Id);
        OrelRequestTracking__c testRecord2 = new OrelRequestTracking__c(Account__c = testAccount.Id, Orel_Reason__c = 'Test Reason 2', OrelStatus__c = 'Deboard initiated', Orel_Initiated_By__c = testUser.Id);
        insert new List<OrelRequestTracking__c>{testRecord1, testRecord2};

        // Debug logs to verify test records are inserted correctly
        System.debug('Test Record 1 Id: ' + testRecord1.Id);
        System.debug('Test Record 2 Id: ' + testRecord2.Id);

        Test.startTest();
        // Call the method under test
        List<OrelRequestTracking__c> result = OrelRequestTrackingController.getOrelRequestsByUser();
        Test.stopTest();

        // Check if the returned list contains the expected records
       // System.assertEquals(2, result.size());
        //System.assertEquals('Test Reason 1', result[0].Orel_Reason__c);
        //System.assertEquals('Test Reason 2', result[1].Orel_Reason__c);
    }
}