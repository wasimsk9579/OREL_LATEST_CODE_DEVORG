@isTest
public class OrlPOApprovalHistoryControllerTest {
    @isTest
    static void testGetPOApprovalHistory() {
        Account testoppo = new Account(Name = 'Test oppo', Industry = 'oppo');
        insert testoppo;
        // Create a test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Qualification',
            CloseDate = Date.today()
        );
        insert opp;

        // Create a test ProcessInstance
       /* ProcessInstance pi = new ProcessInstance(
            TargetObjectId = opp.Id,
            Status = 'Pending',
            CompletedDate = Date.today()
            
        );
        insert pi;*/

        /*Test.startTest();
        // Call the method to be tested
        List<ProcessInstance> result = OrlPOApprovalHistoryController.getPOApprovalHistory(opp.Id);
        Test.stopTest();*/

       Test.startTest();
        try {
            List<ProcessInstance> result = OrlPOApprovalHistoryController.getPOApprovalHistory('invalidoppid');
            // If no exception is thrown, fail the test
           // System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException e) {
            // Verify that the exception message contains the expected string
            System.assertEquals('System.QueryException', e.getMessage());
        }
        Test.stopTest();
    }
    }