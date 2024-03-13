public class FOC_Creation 
{
    @InvocableMethod
    public static List<String> addFreeItems(List<Id> ordersList) 
    {
        System.debug('ordersList::'+ordersList);
        //ordersList = new List<Id>();
        //ordersList.add('a3c1m000000MIlnAAG'); 
        System.debug('Entered::');
        System.debug('ordersList::'+ordersList);
        List<String> testReturn = new List<String>(); 
        testReturn.add('testing');
        List<cgcloud__Order_Item__c> ItemList = [Select Id, cgcloud__Quantity__c, cgcloud__Product__c, cgcloud__Order__c from cgcloud__Order_Item__c where cgcloud__Order__c IN :ordersList];
        List<cgcloud__Order_Item__c> itemInsertList = new List<cgcloud__Order_Item__c>();
        //List<cgcloud__Order__c> orderList = [Select Id, (Select Id, cgcloud__Product__c from cgcloud__Order_Items__r) from cgcloud__Order__c where Id IN :Trigger.new];
        //Map<Id,cgcloud__Order__c> orderMap = new Map<Id,cgcloud__Order__c>(orderList);
        Set<Id> prodIds = new Set<Id>();
        List<cgcloud__Order_Item__c> insertList = new List<cgcloud__Order_Item__c>();
        List<Product2> prodList = new List<Product2>();
        Map<Id, Product2> prodDetails;
        Map<Id,Map<Decimal, Decimal>> focMap = new Map<Id,Map<Decimal, Decimal>>();
        if(ItemList!=null && ItemList.size()>0)
        {
            for(cgcloud__Order_Item__c cod : ItemList)
        {
            prodIds.add(cod.cgcloud__Product__c);
        }
        System.debug('prodIds'+prodIds);
        prodList = [Select Id, (Select Id, Base_Quantity__c, FOC_Quantity__c from FOC_Conditions__r) from Product2 where Id IN :prodIds];
        prodDetails = new Map<Id,Product2>(prodList);
        for(Id prod: prodIds)
        {
            Map<Decimal, Decimal> focDetails = new Map<Decimal, Decimal>();
            if(prodDetails.containsKey(prod) && prodDetails.get(prod).FOC_Conditions__r.size()>0)
               {
                   for(FOC_Condition__c foc: prodDetails.get(prod).FOC_Conditions__r)
                   {
                       focDetails.put(foc.Base_Quantity__c, foc.FOC_Quantity__c);
                   }
               }
            if(!focDetails.isEmpty())
                focMap.put(prod, focDetails);
        }
        
        if(ItemList!=null && ItemList.size()>0)
        {
            for(cgcloud__Order_Item__c orderItem : ItemList)
            {
                cgcloud__Order_Item__c newOrderItem = new cgcloud__Order_Item__c();
                if(orderItem.cgcloud__Quantity__c>0 && focMap.get(orderItem.cgcloud__Product__c).containsKey(orderItem.cgcloud__Quantity__c))
                {
                    newOrderItem.cgcloud__Product__c = orderItem.cgcloud__Product__c;
                    newOrderItem.cgcloud__Order__c = orderItem.cgcloud__Order__c;
                    newOrderItem.cgcloud__Quantity__c = focMap.get(orderItem.cgcloud__Product__c).get(orderItem.cgcloud__Quantity__c);
                    insertList.add(newOrderItem);
                    orderItem.FOC_added__c = true;
                    itemInsertList.add(orderItem);             
                }
            }
        }
            System.debug('insertList::'+insertList);
        System.debug('itemInsertList::'+itemInsertList); 
        if(insertList!=null && insertList.size()>0)
            insert insertList;
        //if(itemInsertList!=null && itemInsertList.size()>0)
            //update itemInsertList;
        }
        
            return testReturn;

        }
}