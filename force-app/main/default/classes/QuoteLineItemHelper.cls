public class QuoteLineItemHelper {
/*
    public static void updateMarginOpp(List<Quotelineitem> newQuotelineitems) {
        Set<Id> QuoteIds = new Set<Id>();

        // Collect Quote Ids from the Quotelineitems being inserted
        for (Quotelineitem oli : newQuotelineitems) {
        	QuoteIds.add(oli.QuoteId);
        }

        // Query Quotes with their Margin values
        Map<Id, Quote> QuoteWithMargins = new Map<Id, Quote>(
            [SELECT Id, Gross_Margin__c FROM Quote WHERE Id IN :QuoteIds]
        );

        // Update Margin Opp on each Quotelineitem with the corresponding Quote's Margin
        for (Quotelineitem qli : newQuotelineitems) {
            if (QuoteWithMargins.containsKey(qli.QuoteId)) {
                qli.Gross_Margin__c = QuoteWithMargins.get(qli.QuoteId).Gross_Margin__c;
            }
        }
    }
   */ 
}