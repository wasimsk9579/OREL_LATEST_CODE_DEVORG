public class StockAuditController {
    public Stock_Audit__c Stocks {get;set;}
    private final Stock_Audit__c originalStocks;
    public list<Stock_Audit_Line_Item__c> StockLineItems {get;set;}

    public StockAuditController(ApexPages.StandardController stdController) {

        this.originalStocks = (Stock_Audit__c)stdController.getRecord();
        System.debug('OriginalStocks=> '+this.originalStocks);

        Stocks = [Select Id,Name,Audit_Date__c,(Select Id,Name,Orl_Actual_Quantity__c from Stock_Audit_Line_Items__r),Customer__r.Name,Inventory_Type__c from Stock_Audit__c where Id=:originalStocks.Id];
        
        StockLineItems = [Select Id,Name,Orl_Actual_Quantity__c,Orl_Expected_Quantity__c,Orl_Product_Name__c,Orl_Inventory_Type__c,Orl_Inventory__c
                           from Stock_Audit_Line_Item__c where Orl_Stock_Audit__c =:Stocks.Id];

        

    }
}