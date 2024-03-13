@isTest
private class OrlretailStoreListControllerTest {

    static testMethod void testGetRest() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Retrieve the standard user profile
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        // Create a test user associated with the test account using the standard user profile
        User testUser = new User(
            FirstName = 'Test999',
            LastName = 'User',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            Username = 'testuser@example999.com',
            CommunityNickname = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US', // Add LanguageLocaleKey field
            ProfileId = standardUserProfile.Id, // Assigning the standard user profile
            UserRoleId = null, // Ensure UserRoleId is null for standard users
            IsActive = true // Ensure the user is active
        );
        insert testUser;

        // Call the method to test
        Test.startTest();
        List<Account_Retail_Store__c> result = OrlretailStoreListController.getRest(testUser.Id);
        Test.stopTest();

        // Perform assertions
        System.assertEquals(0, result.size(), 'No retail store records should be returned because the user is not associated with any retail store');
    }
}