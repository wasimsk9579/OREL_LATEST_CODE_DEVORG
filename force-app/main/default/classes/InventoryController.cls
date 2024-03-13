public class InventoryController {
    
    @auraenabled(cacheable=true)
    public static List<cgcloud__Inventory__c> getInventoryList(){
        
        List<cgcloud__Inventory__c> inventoryList = [SELECT Id, cgcloud__Account__c, cgcloud__Account__r.Name, cgcloud__Product__c, cgcloud__Product__r.Name,Inventory_Control_Template_Type__c,
                                                     Orl_Inventory_type__c, cgcloud__Balance__c, Name
                                                     FROM cgcloud__Inventory__c 
                                                     WHERE cgcloud__Account__c != null 
                                                     ORDER BY CreatedDate];
        Return inventoryList; 
    }
    
    @AuraEnabled()
    public static string createStockAudit(List<InventoryWrapper> datalist, string selectedAccountName) {
        List<Stock_Audit_Line_Item__c> lineItems = new List<Stock_Audit_Line_Item__c>();
        Stock_Audit__c stAudit = new Stock_Audit__c();
        stAudit.Audit_Date__c = system.today();
        If(selectedAccountName != '' && selectedAccountName != null){
            stAudit.Customer__c = selectedAccountName;
        }
        
        insert stAudit;
        
        for (InventoryWrapper ip : datalist) {
            system.debug('inventory>>' + JSON.serializePretty(ip));
            
            Stock_Audit_Line_Item__c stlineItem = new Stock_Audit_Line_Item__c();
            stlineItem.Orl_Actual_Quantity__c = ip.Actual_Amount;
            stlineItem.Orl_Expected_Quantity__c = ip.cgcloud_Balance;
            stlineItem.Orl_Product_Name__c = ip.Name;
            stlineItem.Orl_Stock_Audit__c = stAudit.Id;
            stlineItem.Orl_Inventory_Type__c = ip.Inventory_Type;
            stlineItem.Orl_Inventory__c = ip.Id;
            
            
            lineItems.add(stlineItem);
        }
        
        insert lineItems;
        
        return 'accepted';
    }
    
    
    public class InventoryWrapper {
        @AuraEnabled public Id Id { get; set; }
        @AuraEnabled public Decimal cgcloud_Balance { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String Inventory_Type { get; set; }
        @AuraEnabled public Decimal Actual_Amount { get; set; }
        
        public InventoryWrapper() {}

    }
    
}