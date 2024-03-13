// OrelRequestTrackingController.cls
public with sharing class OrelRequestTrackingController {

    @AuraEnabled(cacheable=true)
    public static List<OrelRequestTracking__c> getOrelRequestsByUser() {
        // Get the current user's Id
        Id userId = UserInfo.getUserId();

        // Query the User's related Account Id
        Id userAccountId = [SELECT AccountId FROM User WHERE Id = :userId].AccountId;

        // Perform SOQL query to fetch OrelRequestTracking__c records based on the user's Account
        return [SELECT Id, Name, Account__c, Account__r.Name, Orel_Reason__c, OrelStatus__c, Orel_Initiated_By__c
                FROM OrelRequestTracking__c
                WHERE Account__c = :userAccountId];
    }
}