public without sharing class OrelDeboardingController {
    @AuraEnabled
    public static void createOrelRequestRecord(String userId, String reason) {
        String usacId = [SELECT Id, AccountId FROM User WHERE Id = :userId LIMIT 1].AccountId;
        system.debug('Print' +usacId);
        // Create a new OrelRequestTracking__c record
        OrelRequestTracking__c orelRequestRecord = new OrelRequestTracking__c(
            Account__c = usacId,
            Orel_Initiated_By__c = 'Initiated by Distributor',
            OrelStatus__c = 'Deboard initiated',
            Orel_Reason__c = reason
        );

        // Insert the new OrelRequestTracking__c record
        insert orelRequestRecord;
    }

    @AuraEnabled
    public static void updateAccountNonDist(String accountId, String reason) {
        system.debug('Entered apec class ' + accountId);
        Account acc = [SELECT Id, De_Boarding_Reason__c, Deboarding_process_status__c FROM Account WHERE Id = :accountId];
        system.debug('account list ' + acc);
        acc.De_Boarding_Reason__c = reason;
        acc.Deboarding_process_status__c = 'In Process - Working with Reconciliation & Full and Final Settlement';
        acc.orel_Deboard_Initiated__c ='Initiated by Non-Distributor';
        update acc;
    }
}