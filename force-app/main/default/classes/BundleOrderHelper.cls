public class BundleOrderHelper {
    @AuraEnabled
    public String key; // Map key
    
    @AuraEnabled
    public cgcloud__Order_Item__c value; // Map value    
    
    
    @InvocableVariable
    Public string UserId;
    
    @InvocableMethod(label = 'Bundle Helper')
    public static void BundleOrders(List<InputVariables> InputVariables) {
        
        List<cgcloud__Order__c> ordersUpdate = new List<cgcloud__Order__c>();
        Set<Id> oIdList = new Set<Id>();
        
        Map<Id,List<cgcloud__Order_Item__c>> mapidToOrderList = new Map<Id,List<cgcloud__Order_Item__c>>();
        Map<Id,Id> mapItemIdToOrderId = new Map<Id,Id>();
        
        
        Map<Id,cgcloud__Order_Item__c> mapProductIdToItem = new Map<Id,cgcloud__Order_Item__c>();
        
        For(cgcloud__Order_Item__c item : InputVariables.get(0).OrderItemList){
            
            If(!mapProductIdToItem.containsKey(item.cgcloud__Product__c)){
                cgcloud__Order_Item__c oItem = new cgcloud__Order_Item__c();
                oItem.cgcloud__Order__c = InputVariables.get(0).OrderId;
                
            }
        } 
    }
    
    Public class InputVariables{
        
        @InvocableVariable
        Public string UserId;
        
        @InvocableVariable
        Public string OrderId;
        
        @InvocableVariable
        Public List<cgcloud__Order_Item__c> OrderItemList;
    }
}