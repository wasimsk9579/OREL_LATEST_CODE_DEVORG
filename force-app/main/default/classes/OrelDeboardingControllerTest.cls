@isTest
private class OrelDeboardingControllerTest {
    @isTest
    static void testCreateOrelRequestRecord() {
        // Test data setup
        String userId = UserInfo.getUserId();
        String reason = 'Test Reason';

        // Call the method
        Test.startTest();
        OrelDeboardingController.createOrelRequestRecord(userId, reason);
        Test.stopTest();

        // Verification
        // Check if OrelRequestTracking__c record is created
        Integer recordCount = [SELECT count() FROM OrelRequestTracking__c];
        System.assertEquals(1, recordCount, 'OrelRequestTracking__c record should be created.');

        // Additional verification if required
    }

    @isTest
    static void testUpdateAccountNonDist() {
        // Test data setup
        Account testAccount = new Account(
            Name = 'Test Account'
            // Add other required fields
        );
        insert testAccount;

        String accountId = testAccount.Id;
        String reason = 'Test Reason';

        // Call the method
        Test.startTest();
        OrelDeboardingController.updateAccountNonDist(accountId, reason);
        Test.stopTest();

        // Verification
        // Verify the update on the Account
        Account updatedAccount = [SELECT Id, De_Boarding_Reason__c, Deboarding_process_status__c, orel_Deboard_Initiated__c FROM Account WHERE Id = :accountId];
        System.assertEquals(reason, updatedAccount.De_Boarding_Reason__c, 'De_Boarding_Reason__c should be updated.');
        System.assertEquals('In Process - Working with Reconciliation & Full and Final Settlement', updatedAccount.Deboarding_process_status__c, 'Deboarding_process_status__c should be updated.');
        System.assertEquals('Initiated by Non-Distributor', updatedAccount.orel_Deboard_Initiated__c, 'orel_Deboard_Initiated__c should be updated.');

        // Additional verification if required
    }
}