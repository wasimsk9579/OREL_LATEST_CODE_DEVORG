public class ProductSearchAddController 
{
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts()
    {
        List<Product2> prodList = [SELECT Id, Name, Description, ProductCode, IsActive, cgcloud__Product_Template__r.Name FROM Product2];
        return prodList;
    }

    @AuraEnabled
    public static void createOrderItems(String itemsMap, String orderId) 
    { 
        System.debug('itemsMap::'+itemsMap);
        itemsMap = '['+itemsMap+']';
        System.debug('orderId::'+orderId);
        List<object> itemsList = (List<object>)JSON.deserializeUntyped(itemsMap);
        Map<String,Object> quantMap;
        for(Object obj: itemsList) 
        {
            quantMap = (Map<String,Object>)obj;
        }
        System.debug('quantMap::'+quantMap);
        List<Product2> prodList = [SELECT Id, Name, ProductCode, IsActive FROM Product2 where Id IN :quantMap.KeySet()];
        List<cgcloud__Product_Condition__c> pcList = [SELECT Id, cgcloud__Product__c, cgcloud__Value__c FROM cgcloud__Product_Condition__c where cgcloud__Product__c IN :quantMap.KeySet()];
        List<PricebookEntry> pbList = [SELECT Id, Pricebook2Id, Product2Id, UnitPrice FROM PricebookEntry where Product2Id IN :quantMap.KeySet()];
        Map<Id,Product2> prodMap = new Map<Id,Product2>(prodList);
        Map<Id, Decimal> priceMap = new Map<Id,Decimal>();
        cgcloud__Order__c order = new cgcloud__Order__c();
        order = [Select Id, cgcloud__Order_Template__r.Name from cgcloud__Order__c where Id = :orderId LIMIT 1];
        List<cgcloud__Order_Item__c> itemInsertList = new List<cgcloud__Order_Item__c>();
        if(order.cgcloud__Order_Template__r.Name == 'Sales Template')
        {
            for(cgcloud__Product_Condition__c pc: pcList)
            {
                System.debug('Pricing calculation');
                priceMap.put(pc.cgcloud__Product__c, pc.cgcloud__Value__c);
            }
        }else{
            for(PricebookEntry pb : pbList)
            {
                priceMap.put(pb.Product2Id, pb.UnitPrice);
            }
        }
        for(String prodId: quantMap.KeySet())
        {
            System.debug('Order Item creation entered::');
            cgcloud__Order_Item__c orderItem = new cgcloud__Order_Item__c();
            orderItem.cgcloud__Order__c = orderId;
            orderItem.cgcloud__Quantity__c = Decimal.valueOf((String)quantMap.get(prodId));
            System.debug('Quantity'+orderItem.cgcloud__Quantity__c);
            orderItem.cgcloud__Product__c = prodId;
            orderItem.cgcloud__Price__c = priceMap.get(prodId);
            itemInsertList.add(orderItem);
        }

        if(itemInsertList!=null && itemInsertList.size()>0)
        insert itemInsertList;

    }

    @AuraEnabled(cacheable=true)
    public static List<cgcloud__Order_Item__c> getOrderItems(String orderId)
    {
        List<cgcloud__Order_Item__c> itemList = [SELECT Id, Name, cgcloud__Order__c, cgcloud__Price__c, cgcloud__Discount__c, cgcloud__Product__r.Name, cgcloud__Quantity__c, cgcloud__Value__c, cgcloud__Order_Item_Template__r.Name FROM cgcloud__Order_Item__c where cgcloud__Order__c = :orderId];
        return itemList;
    }
    
    @AuraEnabled
    public static void updateOrderItems(String itemsMap, String orderId)
    {
        System.debug('itemsMap::'+itemsMap);
        itemsMap = '['+itemsMap+']';
        System.debug('orderId::'+orderId);
        List<object> itemsList = (List<object>)JSON.deserializeUntyped(itemsMap);  
        Map<String,Object> quantMap;
        List<cgcloud__Order_Item__c> updateItemsList = new List<cgcloud__Order_Item__c>();
        for(Object obj: itemsList) 
        {
            quantMap = (Map<String,Object>)obj;
        }
        System.debug('quantMap::'+quantMap);
        List<cgcloud__Order_Item__c> items = [SELECT Id, cgcloud__Quantity__c FROM cgcloud__Order_Item__c where Id IN :quantMap.Keyset()];
        for(cgcloud__Order_Item__c item: items)
        {
            item.cgcloud__Quantity__c = Decimal.valueOf((String)quantMap.get(item.Id));
            updateItemsList.add(item);
        }
        if(updateItemsList!=null && updateItemsList.size()>0)
        update updateItemsList;
    }
}