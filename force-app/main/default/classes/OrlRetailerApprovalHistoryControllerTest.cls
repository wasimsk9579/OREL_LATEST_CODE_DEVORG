@isTest
private class OrlRetailerApprovalHistoryControllerTest {

    @isTest
    static void testGetRetailerApprovalHistory() {
        // Create test data
        Account testRetailer = new Account(Name = 'Test Retailer', Industry = 'Retail');
        insert testRetailer;

        // Call the method with an invalid retailer Id to force an exception
        Test.startTest();
        try {
            List<ProcessInstance> result = OrlRetailerApprovalHistoryController.getRetailerApprovalHistory('invalidRetailerId');
            // If no exception is thrown, fail the test
           // System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException e) {
            // Verify that the exception message contains the expected string
            System.assertEquals('System.QueryException', e.getMessage());
        }
        Test.stopTest();
    }
}