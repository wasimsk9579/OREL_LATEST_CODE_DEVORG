public class FreeItemAdditionToRunner {

      @InvocableMethod
    public static List<String> itemInclusion(List<Id> opportunityLineItemIds)
    {
        List<String> testReturn = new List<String>(); 
        testReturn.add('testing');
        
        List<OpportunityLineItem> opportunityLineItemList = [SELECT Id, Quantity, Product2Id, OpportunityId FROM OpportunityLineItem WHERE Id IN :opportunityLineItemIds];
        Set<Id> productIds = new Set<Id>();
        List<FOC_Condition__c> focList = new List<FOC_Condition__c>();
        Map<Id, Map<Decimal, Decimal>> focMap = new Map<Id, Map<Decimal, Decimal>>();
        List<OpportunityLineItem> itemInsertList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> itemUpdateList = new List<OpportunityLineItem>();
        if(opportunityLineItemList != null && opportunityLineItemList.size() > 0)
        {
            for(OpportunityLineItem oli : opportunityLineItemList)
            {
                productIds.add(oli.Product2Id);
            }
        }
        focList = [SELECT Id, Product__c, Base_Quantity__c, FOC_Quantity__c FROM FOC_Condition__c WHERE Product__c IN :productIds ORDER BY Base_Quantity__c ASC];
        for(FOC_Condition__c foc : focList)
        {
            Map<Decimal, Decimal> focEntry = new Map<Decimal, Decimal>();
            if(focMap.containsKey(foc.Product__c))
            {
                focEntry = focMap.get(foc.Product__c);
                focEntry.put(foc.Base_Quantity__c, foc.FOC_Quantity__c);
                focMap.put(foc.Product__c, focEntry);
            }else{
                focEntry.put(foc.Base_Quantity__c, foc.FOC_Quantity__c);  
                focMap.put(foc.Product__c, focEntry);
            }
        }
        System.debug('focMap::'+focMap);
        if(opportunityLineItemList != null && opportunityLineItemList.size() > 0)
        {
              System.debug('first If::');
            for(OpportunityLineItem oppLineItem : opportunityLineItemList)
            {
                System.debug('items_for::');
                OpportunityLineItem newOppLineItem = new OpportunityLineItem();
                  if(focMap.containsKey(oppLineItem.Product2Id))
            {
                  System.debug('second if::');
                    List<Decimal> keyList = sortList(focMap.get(oppLineItem.Product2Id)); //5 10
                System.debug('keyList::'+keyList);
                    if(oppLineItem.Quantity>0 && oppLineItem.Quantity>=keyList.get(0) &&focMap.get(oppLineItem.Product2Id).keySet().size()>0)
                    {
                        System.debug('third if::');
                        Decimal thisIt = 0;
                 for(Decimal key : keyList)
                        {
                            thisIt++;
                            if(key>oppLineItem.Quantity)
                            {
                                break;                           
                            }
                        }   
                 newOppLineItem.Product2Id = oppLineItem.Product2Id;
                    newOppLineItem.OpportunityId = oppLineItem.OpportunityId;
                    newOppLineItem.TotalPrice = 1;
                    newOppLineItem.Free_Item__c = true;
                    Decimal index = (Decimal)keyList.get((Integer)thisIt-2);
                    newOppLineItem.Quantity = focMap.get(oppLineItem.Product2Id).get(index);
                    itemInsertList.add(newOppLineItem);
                         System.debug('itemInsertList::'+itemInsertList);
                    oppLineItem.FOC_added__c = true;
                    itemUpdateList.add(oppLineItem); 
                    }
            }
            }
        }

          if(itemInsertList!=null && itemInsertList.size()>0)
            insert itemInsertList;
        if(itemUpdateList!=null && itemUpdateList.size()>0)
            update itemUpdateList;
            
        return testReturn;
        
    }       

    public static List<Decimal> sortList(Map<Decimal, Decimal> deciMap)
    {
        Set<Decimal> recSet = deciMap.keySet();
        List<Decimal> unsortList = new List<Decimal>();

        if(unsortList.size() > 1)
            unSortList.addAll(recSet);
        else
        {
            unSortList.addAll(recSet);
            unSortList.add(unSortList.get(0) + 1);
        }

        return unSortList;
    }
}