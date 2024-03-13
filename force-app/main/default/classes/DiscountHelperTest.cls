@isTest(SeeAllData=false)
public class DiscountHelperTest {
    
    @IsTest
    //Unit test unitTestgetProducts
    private static void unitTestgetOpportunityLineItems(){
        List<Opportunity> opportunityList = TestDataFactory.createOpportunity(1);
        System.debug('opportunityList cls ===>' + opportunityList);
        String pricebookEntryId = '01u1m000004JTWWAA4'; 
        List<OpportunityLineItem> opportunityLineItemList = TestDataFactory.createOpportunityLineItem(opportunityList, pricebookEntryId);
        
        
        //insert opportunityList;
        //insert opportunityLineItemList;
        
        // Modify some Opportunity fields
        for(Opportunity opp : opportunityList){
            opp.AFP_Perent__c = 20;
            opp.PFP_Percent__c = 20;
            opp.TPC_Percent__c = 20;
        }
        update opportunityList;
        
        // Retrieve the updated OpportunityLineItems
        List<OpportunityLineItem> updateOpportunityLineItemList = [SELECT Id, AFP_Percent__c, PFP_Percent__c, TPC_Percent__c  
                                                                   FROM OpportunityLineItem 
                                                                   WHERE OpportunityId IN :opportunityList];
        
        for(OpportunityLineItem opli : updateOpportunityLineItemList){
            
        }
    }
    
    @IsTest
    //bulk test bulkTestgetProducts
    private static void bulkTestgetOpportunityLineItems(){
        List<Opportunity> opportunityList = TestDataFactory.createOpportunity(50);
        System.debug('opportunityList cls ===>' + opportunityList);
        String pricebookEntryId = '01u1m000004JTWWAA4'; 
        List<OpportunityLineItem> opportunityLineItemList = TestDataFactory.createOpportunityLineItem(opportunityList, pricebookEntryId);
        
        // Modify some Opportunity fields
        for(Opportunity opp : opportunityList){
            opp.AFP_Perent__c = 20;
            opp.PFP_Percent__c = 20;
            opp.TPC_Percent__c = 20;
        }
        update opportunityList;
        
        Set<Id> opportunityIds = new Set<Id>();
        for (Opportunity opp : opportunityList) {
            opportunityIds.add(opp.Id);
        }
        // Retrieve the updated OpportunityLineItems
        List<OpportunityLineItem> updateOpportunityLineItemList = [SELECT Id, AFP_Percent__c, PFP_Percent__c, TPC_Percent__c  
                                                                   FROM OpportunityLineItem 
                                                                   WHERE OpportunityId IN :opportunityIds];
    }
    
    @isTest
    private static void unitTestgetQuoteLineItems() {
        
        List<Opportunity> opportunityList = TestDataFactory.createOpportunity(1);
        
        List<Quote> quoteList = TestDataFactory.createQuote(3, opportunityList[0].Id);
        
        PricebookEntry testPricebookEntry;
        Pricebook2 standardPricebook;
        try {
            standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
            testPricebookEntry = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :standardPricebook.Id LIMIT 1];
        } catch (QueryException e) {
            return;
        }
        DiscountHelper.getQuoteLineItems(quoteList, new Map<Id, Quote>());
        
        String pricebookEntryId = testPricebookEntry.Id;
        List<QuoteLineItem> QuoteLineItemList = TestDataFactory.createQuoteLineItem(quoteList, pricebookEntryId);
        
        for (Quote qt : quoteList) {
            qt.AFPPerent__c = 10;
            qt.PFPPERCENT__c = 10;
            qt.TPCpercent__c = 10;
        }
        
        List<QuoteLineItem> UpdateQuoteLineItemList = [SELECT Id, AFPpercent__c, PFPPERCENT__c, TPCpercent__c, QuoteId FROM QuoteLineItem WHERE QuoteId IN :quoteList];
        for (QuoteLineItem qti : UpdateQuoteLineItemList) {
            
        }
    }
}