@isTest(SeeAllData = true)
private class OrlReatilerApprovalControllerTest {
    
   @isTest
    static void testGetApprovalStatus() {
        // Test data setup
        Account_Retail_Store__c store = new Account_Retail_Store__c();
        insert store;
        ProcessInstance procins = new ProcessInstance();
        procins.TargetObjectId=store.Id;
        procins.Status='Pending';
        procins.ProcessDefinitionId = null;
       // insert procins;
        list<ProcessInstance> test =[SELECT Id, TargetObjectId, Status, LastModifiedDate 
                                            FROM ProcessInstance where status = 'Approved' LIMIT 1];

        // Test method invocation
        String status = OrlReatilerApprovalController.getApprovalStatus(Test[0].TargetObjectId);

        // Assertion
        System.assertEquals('Approved', status, 'Approval status should be null as there are no process instances');
    }

    @isTest
    static void testGetRetailInformation() {
        // Test data setup
        Account_Retail_Store__c store = new Account_Retail_Store__c();
        insert store;
//ProcessInstanceWorkitem workItem = new ProcessInstanceWorkitem();
        //insert workItem;
        // Test method invocation
        Account_Retail_Store__c result = OrlReatilerApprovalController.getRetailInformation(store.Id);

        // Assertion
        System.assertNotEquals(null, result, 'Retail information should not be null');
    }

    @isTest
    static void testApproveOrRejectRetailerRecord() {
         schema.Account_Retail_Store__c rtStore = [SELECT Id,OwnerId, Name, Status__c,Description__c,Active__c
                                FROM Account_Retail_Store__c limit 1];
                ProcessInstanceWorkitem workItem = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :rtStore.id];

        // Test data setup
        Account_Retail_Store__c store = new Account_Retail_Store__c();
        insert store;
       // list<ProcessInstance> test =[SELECT Id, TargetObjectId, Status, LastModifiedDate 
                                         //   FROM ProcessInstance LIMIT 1];

        // Test method invocation - Approve case
       // Test.startTest();
        OrlReatilerApprovalController.approveOrRejectRetailerRecord(rtstore.Id, 'Approve', 'Approved');
        //OrlReatilerApprovalController.approveOrRejectRetailerRecord(rtstore.Id, 'Reject', 'Rejected');
       // Test.stopTest();

       
    }
    @isTest
    static void testRejectRetailerRecord() {
         schema.Account_Retail_Store__c rtStore = [SELECT Id,OwnerId, Name, Status__c,Description__c,Active__c
                                FROM Account_Retail_Store__c limit 1];
                ProcessInstanceWorkitem workItem = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :rtStore.id];

        // Test data setup
        Account_Retail_Store__c store = new Account_Retail_Store__c();
        insert store;
       // list<ProcessInstance> test =[SELECT Id, TargetObjectId, Status, LastModifiedDate 
                                         //   FROM ProcessInstance LIMIT 1];

        // Test method invocation - Approve case
       // Test.startTest();
       // OrlReatilerApprovalController.approveOrRejectRetailerRecord(rtstore.Id, 'Approve', 'Approved');
        OrlReatilerApprovalController.approveOrRejectRetailerRecord(rtstore.Id, 'Reject', 'Rejected');
       // Test.stopTest();

       
    }
}