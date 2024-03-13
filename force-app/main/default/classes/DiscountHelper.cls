public class DiscountHelper {
    public static void getOpportunityLineItems(List<Opportunity> newOpp, Map<Id, Opportunity> oldOppMap){
        List<OpportunityLineItem> productsToUpdate = new List<OpportunityLineItem>();
        for(Opportunity oppnew : newOpp){
            Opportunity oppold = oldOppMap.get(oppnew.Id);
            
            if(oppnew.AFP_Perent__c !=oppold.AFP_Perent__c || oppnew.PFP_Percent__c != oppold.PFP_Percent__c || oppnew.TPC_Percent__c != oppold.TPC_Percent__c){
                List<OpportunityLineItem> productList = [SELECT id, AFP_Percent__c, PFP_Percent__c, TPC_Percent__c  from OpportunityLineItem WHERE OpportunityId=: oppnew.Id ];
                for(OpportunityLineItem oli : productList){
                    oli.AFP_Percent__c = oppnew.AFP_Perent__c;
                    oli.PFP_Percent__c= oppnew.PFP_Percent__c;
                    oli.TPC_Percent__c = oppnew.TPC_Percent__c;
                    productsToUpdate.add(oli);
                }
            }  
        }
        if(!productsToUpdate.isEmpty()){
            Update productsToUpdate;
        } 
    }
    
    public static void getQuoteLineItems(List<Quote> newQuotes, Map<Id, Quote> oldQuoteMap){
        List<QuoteLineItem> UpdateQuoteLineItem = new List<QuoteLineItem>();
        
        for(Quote qtnew: newQuotes){
            Quote quoteOld =oldQuoteMap.get(qtnew.Id);
            
            if(qtnew.AFPPerent__c != quoteOld.AFPPerent__c || qtnew.PFPPERCENT__c != quoteOld.PFPPERCENT__c || qtnew.TPCpercent__c != quoteOld.TPCpercent__c){
                List<QuoteLineItem> QuoteLineItemList =[SELECT id,AFPpercent__c, PFPPERCENT__c, TPCpercent__c, QuoteId, Quote.name from QuoteLineItem WHERE QuoteId=: qtnew.Id];
                for(QuoteLineItem qli : QuoteLineItemList){
                    qli.AFPpercent__c= qtnew.AFPPerent__c;
                    qli.PFPPERCENT__c= qtnew.PFPPERCENT__c;
                    qli.TPCpercent__c= qtnew.TPCpercent__c;
                    UpdateQuoteLineItem.add(qli);
                }
            }
        }
        if(!UpdateQuoteLineItem.isEmpty()){
            update UpdateQuoteLineItem;
        }
    }
    
}