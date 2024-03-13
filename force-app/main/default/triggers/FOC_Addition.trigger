trigger FOC_Addition on cgcloud__Order_Item__c (after insert, after update) 
{
    /************************************************************************************/
    //Edited By Sudarshan N B
    
    OrderItemTriggerHandler.UpdateHandler(trigger.new, trigger.oldmap);
    
    /**************************************************************************************/
    
    List<cgcloud__Order_Item__c> insertList = new List<cgcloud__Order_Item__c>();
    Set<Id> prodIds = new Set<Id>();
    for(cgcloud__Order_Item__c cod : Trigger.new)
    {
       prodIds.add(cod.cgcloud__Product__c);
    }
    List<Product2> prodList = [Select Id, (Select Id, Base_Quantity__c, FOC_Quantity__c from FOC_Conditions__r) from Product2 where Id IN :prodIds];
    Map<Id, Product2> prodDetails = new Map<Id,Product2>(prodList);
    for(cgcloud__Order_Item__c cod : Trigger.new)
    {
        Map<Decimal, Decimal> focMap = new Map<Decimal, Decimal>();
        cgcloud__Order_Item__c newOrderItem = new cgcloud__Order_Item__c();
       if(prodDetails.containsKey(cod.cgcloud__Product__c) && prodDetails.get(cod.cgcloud__Product__c).FOC_Conditions__r.size()>0)
       {
           for(FOC_Condition__c foc: prodDetails.get(cod.cgcloud__Product__c).FOC_Conditions__r)
           {
               focMap.put(foc.Base_Quantity__c, foc.FOC_Quantity__c);
           }
           if(focMap.containsKey(cod.cgcloud__Quantity__c))
           {
               newOrderItem.cgcloud__Product__c = cod.cgcloud__Product__c;
               newOrderItem.cgcloud__Order__c = cod.cgcloud__Order__c;
               newOrderItem.cgcloud__Quantity__c = focMap.get(cod.cgcloud__Quantity__c);
               insertList.add(newOrderItem);
           }
       }
    }
    if(insertList!=null && insertList.size()>0)
        insert insertList;
}