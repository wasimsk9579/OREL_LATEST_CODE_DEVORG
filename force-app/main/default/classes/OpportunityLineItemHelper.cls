public class OpportunityLineItemHelper {

   /*  public static void updateMarginOpp(List<OpportunityLineItem> newOpportunityLineItems) {
        Set<Id> opportunityIds = new Set<Id>();

        // Collect Opportunity Ids from the OpportunityLineItems being inserted
        for (OpportunityLineItem oli : newOpportunityLineItems) {
            opportunityIds.add(oli.OpportunityId);
        }

        // Query Opportunities with their Margin values
        Map<Id, Opportunity> opportunitiesWithMargins = new Map<Id, Opportunity>(
            [SELECT Id, Gross_Margin__c FROM Opportunity WHERE Id IN :opportunityIds]
        );

        // Update Margin Opp on each OpportunityLineItem with the corresponding Opportunity's Margin
        for (OpportunityLineItem oli : newOpportunityLineItems) {
            if (opportunitiesWithMargins.containsKey(oli.OpportunityId)) {
                oli.Gross_Margin__c = opportunitiesWithMargins.get(oli.OpportunityId).Gross_Margin__c;
            }
        }
    }  */
}