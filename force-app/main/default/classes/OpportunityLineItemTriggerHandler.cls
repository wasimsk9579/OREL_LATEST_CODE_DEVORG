public class OpportunityLineItemTriggerHandler {
    public static void createInventoryTransactionRecord(List<OpportunityLineItem> newList) {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Id> opportunityToProductMap = new Map<Id, Id>();
        Map<Id, OpportunityLineItem> opportunityLineItemMap = new Map<Id, OpportunityLineItem>();
        
        // Collect Account Ids and Opportunity to Product mappings
        for (OpportunityLineItem oli : newList) {
            accountIds.add(oli.Opportunity.AccountId);
            opportunityToProductMap.put(oli.OpportunityId, oli.PricebookEntry.Product2Id);
            opportunityLineItemMap.put(oli.Id, oli);
        }
        
        // Query inventories related to the collected Account Ids
        Map<Id, cgcloud__Inventory__c> inventoryMap = new Map<Id, cgcloud__Inventory__c>();
        for (cgcloud__Inventory__c inv : [SELECT Id, cgcloud__Product__c, cgcloud__Account__c 
                                           FROM cgcloud__Inventory__c 
                                           WHERE Orl_Inventory_type__c = 'Whole Inventory' 
                                           AND cgcloud__Account__c IN :accountIds]) {
            inventoryMap.put(inv.cgcloud__Account__c, inv);
        }
        
        List<cgcloud__Inventory_Transaction__c> inventoryTransactionsToInsert = new List<cgcloud__Inventory_Transaction__c>();
        for (OpportunityLineItem oli : newList) {
            if (inventoryMap.containsKey(oli.Opportunity.AccountId) && 
                inventoryMap.get(oli.Opportunity.AccountId).cgcloud__Product__c == opportunityToProductMap.get(oli.OpportunityId)) {
                
                cgcloud__Inventory__c inventory = inventoryMap.get(oli.Opportunity.AccountId);
                
                // Create Inventory Transaction record
                cgcloud__Inventory_Transaction__c inventoryTransaction = new cgcloud__Inventory_Transaction__c();
                inventoryTransaction.cgcloud__Inventory__c = inventory.Id;
                inventoryTransaction.cgcloud__Amount__c = oli.Quantity;
               
                inventoryTransactionsToInsert.add(inventoryTransaction);
            }
        }
        
        // Insert Inventory Transactions
        if (!inventoryTransactionsToInsert.isEmpty()) {
            try {
                insert inventoryTransactionsToInsert;
            } catch (Exception e) {
                // Handle exception
                System.debug('An error occurred: ' + e.getMessage());
            }
        }
    }

///////////////////////////////////////////////////////////////////////////////
 
}