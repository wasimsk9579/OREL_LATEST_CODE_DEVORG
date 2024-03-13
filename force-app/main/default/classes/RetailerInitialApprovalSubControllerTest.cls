@isTest(seealldata=true)
private class RetailerInitialApprovalSubControllerTest {

    @isTest
    static void testSubmitForApproval_Success() {
       Account acc = [select id from Account limit 1];
        
       Account_Retail_Store__c rets = [SELECT Id,Name, Account__c,Status__c FROM Account_Retail_Store__c WHERE Status__c='Distributor-Reject' limit 1];
        // Create test data
       
 List<Contact> contactList = [SELECT Id, AccountId, Is_primary_Contact__c FROM Contact WHERE AccountId = :acc.Id AND Is_primary_Contact__c = true LIMIT 1];

        List<User> userList = [SELECT Id,Name, Username, Email, IsActive, ContactId FROM User WHERE ContactId = :contactList[0].Id AND IsActive = true LIMIT 1];

        // Call the method to be tested
        Test.startTest();
        String result = RetailerInitialApprovalSubController.submitForApproval(rets.Id, 'https://google.com');
        Test.stopTest();

    }

 
  
}