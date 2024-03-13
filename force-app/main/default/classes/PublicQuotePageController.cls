global without sharing class PublicQuotePageController {
    @AuraEnabled
    global static void updateQuoteStatus(String quoteId, String customerResponse) {
        system.debug('quoteId---->'+quoteId);
        List<Quote> updateQuoteList = new List<Quote>();
        try {
      
         List<Quote> quoteList = [SELECT Id, Name, QuoteNumber, Status FROM Quote WHERE Id = :quoteId];
   // Grand_Total_price_with_VAT__c, Additional_Cost__c
   
            system.debug('quoteList--->'+quoteList);  

            for (Quote q : quoteList) {
                System.debug('quotes' + q);
                q.Status = 'Accepted';
                q.Customer_Response__c = customerResponse; // Store customer response
                system.debug('Customer_Response__c is--->' +q.Customer_Response__c);
                updateQuoteList.add(q);  
            }

            system.debug('updateQuoteList--->'+updateQuoteList);  

            if (!updateQuoteList.isEmpty()) {
                update updateQuoteList;  
            }   
        } catch (Exception e) {
            system.debug('updateQuoteStatus exception------->'+e); 
        }
    }

    @AuraEnabled
    global static void updateQuotedenied(String quoteId, String customerResponse) {
        system.debug('quoteId---->'+quoteId);
        List<Quote> deniedQuoteList = new List<Quote>();
        try {
                      List<Quote> quoteList = [SELECT Id, Name, Status, QuoteNumber FROM Quote WHERE Id = :quoteId];  
          
            system.debug('quoteList--->'+quoteList);  

            for (Quote q : quoteList) {
                System.debug('quotes' + q);
                q.Status = 'Denied';
                q.Customer_Response__c = customerResponse; // Store customer response
                system.debug('Customer_Response__c is for denied--->' +q.Customer_Response__c);
                deniedQuoteList.add(q);  
            }

            system.debug('updateQuoteList--->'+deniedQuoteList);  

            if (!deniedQuoteList.isEmpty()) {
                update deniedQuoteList;  
            }   
        } catch (Exception e) {
            system.debug('updateQuoteStatus exception------->'+e); 
        }
    }

    @AuraEnabled(cacheable=true)
    global static List<Quote> getQuoteDetails(String quoteId){
        System.debug('Fetching Quote Details for Id: ' + quoteId);
        try {
             List<Quote> qry = [SELECT Id, Name, Status, QuoteNumber, Customer_Response__c FROM Quote WHERE Id = :quoteId LIMIT 1];
      
            System.debug('Query result for Quote Details: ' + qry);
            return qry;
        } catch (Exception e) {
            // Handle exceptions appropriately
            System.debug('Exception in getQuoteDetails: ' + e.getMessage());
            return null;
        }
    }
}