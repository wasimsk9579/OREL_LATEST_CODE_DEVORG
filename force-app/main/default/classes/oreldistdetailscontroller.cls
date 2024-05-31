public with sharing class oreldistdetailscontroller {
    @AuraEnabled
    public static Account getAccdata(string userId) {
        // Query to get the User's AccountId
        String userAccId = [SELECT AccountId FROM User WHERE Id = :userId].AccountId;

        // Query to get the specific Account record based on the User's AccountId
        Account acc = [SELECT Id, Name, Type, Phone, cgcloud__Account_Email__c, Orel_status__c, Active__c,
                            Type_of_customer__c, Credit_Limit__c, orl_BG_Verified__c,Appointed_Date__c,BG_amount__c,
                            Bank_Guarantee__c, Expiry_date__c,BPR_code__c,Distributor_Catogory__c,VAT_Number__c,
                            Bank_guarantee_Channels__c,Application_Submitted_Date__c,Deboard_Status__c,BillingAddress,(Select Id,Name,AccountId,Is_primary_Contact__c from contacts where Is_primary_Contact__c=true)
                       FROM Account WHERE Id = :userAccId LIMIT 1];

        System.debug('Account Record: ' + acc);
        return acc;
    }
}
