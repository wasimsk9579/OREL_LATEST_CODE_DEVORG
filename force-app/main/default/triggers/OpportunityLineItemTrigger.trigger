trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert) {
    List<OpportunityLineItem> additionalItems = new List<OpportunityLineItem>();
    
    // Map to store product Ids and their corresponding base quantity and additional free quantity
    Map<Id, Decimal[]> productQuantityMap = new Map<Id, Decimal[]>();
    
    // Collect PricebookEntryIds from OpportunityLineItems
    Set<Id> pricebookEntryIds = new Set<Id>();
    for (OpportunityLineItem oli : Trigger.new) {
        pricebookEntryIds.add(oli.PricebookEntryId);
    }
    
    // Query FOC_Condition__c records related to products
    for (FOC_Condition__c foc : [SELECT Product__c, Base_Quantity__c, FOC_Quantity__c 
                                  FROM FOC_Condition__c 
                                  WHERE Product__c IN :pricebookEntryIds]) {
        // Store base and additional quantities in the map
        productQuantityMap.put(foc.Product__c, new Decimal[]{foc.Base_Quantity__c, foc.FOC_Quantity__c});
    }
    
    for (OpportunityLineItem oli : Trigger.new) {
        // Check if the PricebookEntry is not null
        if (oli.PricebookEntry != null) {
            // Check if the quantity is greater than the base quantity
            if (oli.Quantity > productQuantityMap.get(oli.PricebookEntry.Product2Id)[0]) {
                // Calculate the additional quantity based on FOC condition
                Decimal additionalQuantity = productQuantityMap.get(oli.PricebookEntry.Product2Id)[1];
                // Calculate the total quantity to be distributed into multiple items
                Decimal remainingQuantity = oli.Quantity;
                // Create additional OpportunityLineItems until all remaining quantity is distributed
                while (remainingQuantity > 0) {
                    OpportunityLineItem newOli = new OpportunityLineItem();
                    newOli.OpportunityId = oli.OpportunityId;
                    newOli.PricebookEntryId = oli.PricebookEntryId;
                    newOli.Quantity = Math.min(additionalQuantity, remainingQuantity).intValue();
                    newOli.UnitPrice = oli.UnitPrice;
                    additionalItems.add(newOli);
                    remainingQuantity -= additionalQuantity;
                }
            }
        }
    }
    
    // Insert the additional OpportunityLineItems
    if (!additionalItems.isEmpty()) {
        insert additionalItems;
    }
}