public class orelfocclass {
    @InvocableMethod
    public static List<String> itemInclusion(List<Id> itemIds)
    {
        List<String> testReturn = new List<String>(); 
        testReturn.add('testing');
        
        list<OpportunityLineItem> ItemList = [Select Id,Quantity,Product2Id,OpportunityId from OpportunityLineItem where Id IN : itemIds];
      //  List<cgcloud__Order_Item__c> ItemList = [Select Id, cgcloud__Quantity__c, cgcloud__Product__c, cgcloud__Order__c from cgcloud__Order_Item__c where Id IN :itemIds AND FOC_added__c = false];
        Set<Id> prodIds = new Set<Id>();
        List<FOC_Condition__c> focList = new List<FOC_Condition__c>();
        Map<Id,Map<Decimal, Decimal>> focMap = new Map<Id,Map<Decimal, Decimal>>();
        List<OpportunityLineItem> itemInsertList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> itemUpdateList = new List<OpportunityLineItem>();
        
        //List<cgcloud__Order_Item__c> itemInsertList = new List<cgcloud__Order_Item__c>();
        //List<cgcloud__Order_Item__c> itemUpdateList = new List<cgcloud__Order_Item__c>();
       // cgcloud__Order_Item_Template__c itemTemplate = [SELECT Id, Name FROM cgcloud__Order_Item_Template__c where Name = 'Free Item' LIMIT 1];
        if(ItemList!=null && ItemList.size()>0)
        {
            for(OpportunityLineItem cod : ItemList)
            {
                prodIds.add(cod.Product2Id);
            }
        }
        focList = [Select Id, Product__c, Base_Quantity__c, FOC_Quantity__c from FOC_Condition__c where Product__c IN :prodIds ORDER BY Base_Quantity__c asc];
        for(FOC_Condition__c foc: focList)
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
        if(ItemList!=null && ItemList.size()>0)
        {
            System.debug('first If::');
            for(OpportunityLineItem orderItem : ItemList)
            {
                System.debug('items_for::');
                OpportunityLineItem newOrderItem = new OpportunityLineItem();
                if(focMap.containsKey(orderItem.Product2Id))
                {
                    System.debug('second if::');
                    List<Decimal> keyList = sortList(focMap.get(orderItem.Product2Id)); //5 10
                    System.debug('keyList::'+keyList);
                    if(orderItem.Quantity>0 && orderItem.Quantity>=keyList.get(0) &&focMap.get(orderItem.Product2Id).keySet().size()>0)
                    { 
                        System.debug('third if::');
                        Decimal thisIt = 0;
                        //List<> iterKeys = focMap.get(orderItem.cgcloud__Product__c).values(); 
                        
                        for(Decimal key : keyList)
                        {
                            thisIt++;
                            if(key>orderItem.Quantity)
                            {
                                break;                           
                            }
                        }                   
                        newOrderItem.Product2Id = orderItem.Product2Id;
                        newOrderItem.OpportunityId = orderItem.OpportunityId;
                       // newOrderItem.cgcloud__Order_Item_Template__c = itemTemplate.Id;
                        Decimal Index = (Decimal)keyList.get((Integer)thisIt-2);
                        newOrderItem.Quantity = focMap.get(orderItem.Product2Id).get(index);
                        itemInsertList.add(newOrderItem);
                        System.debug('itemInsertList::'+itemInsertList);
                       // orderItem.FOC_added__c = true;
                        itemUpdateList.add(orderItem);             
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
        //Set<Decimal> recDecSet = (Set<Decimal>)JSON.deserialize(JSON.serialize(recSet), Set<Decimal>.class);
        if(unsortList.size()>1)
            unSortList.addAll(recSet);
        else
        {
            unSortList.addAll(recSet);
            unSortList.add(unSortList.get(0)+1);
        }
        return unSortList; 
    }

}