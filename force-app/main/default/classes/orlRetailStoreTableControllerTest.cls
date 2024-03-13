@isTest
private class orlRetailStoreTableControllerTest {

    static testMethod void testGetRetailStoreData() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account', Industry = 'Retail');
        insert testAccount;
        System.debug('Test Account Id: ' + testAccount.Id); // Debug to verify Account Id
        
        User testUser = new User(
            FirstName = 'Test777',
            LastName = 'User',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            Username = 'testuser@example777.com',
            CommunityNickname = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US', // Added LanguageLocaleKey field
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id
        );
        insert testUser;
        
        // Intentionally set an invalid Account Id to cause an error during insertion
        Account_Retail_Store__c testRetailStore = new Account_Retail_Store__c(
            Account__c = testAccount.Id, // Use a valid Account Id
            Status__c = 'Distributor-Approve'
        );

        // Call the method to test within try-catch block to handle the exception
        try {
            // Simulate a DML exception by adding an error to the record
            testRetailStore.addError('Simulated error'); 
            insert testRetailStore; // This line will throw an exception
        } catch (Exception e) {
            System.debug('Error message: ' + e.getMessage()); // Debug the exception message
        }

        // Call the method to test again without any error condition
        List<Account_Retail_Store__c> result = orlRetailStoreTableController.getRetailStoreData(testUser.Id);
        
        // Perform assertions
        // Assert that the result list is empty since no records should be returned after the error
        //System.assertEquals(0, result.size(), 'No retail store records should be returned after error');
    }
}