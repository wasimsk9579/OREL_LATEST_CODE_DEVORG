public class InvoicePdfGeneratorHandler {
    private final Orl_invoice__c originalInvoice;
    public String currentRecordId {get;set;}
    public String parameterValue {get;set;}
    public Orl_invoice__c Invoice{get;set;}
    public String qrcode { get; set; }
    public string inputText {get;set;}
    public string VATNO {get;set;}
    public string TaxType {get;set;}
    public list<cgcloud__Order_Item__c> OrderlineItems {get;set;}
    public string qrcodeurl {get;set;}
    public list<cgcloud__Order_Item__c> OrderItems {get;set;}
    public boolean renderTable {get;set;}
    public cgcloud__Order__c Order {get;set;}
    public static Id recordid;
    public InvoicePdfGeneratorHandler(ApexPages.StandardController stdController) {
        this.originalInvoice = (Orl_invoice__c)stdController.getRecord();
        recordid=originalInvoice.Id;
        System.debug('OriginalInvoice=> '+this.originalInvoice);
        Invoice = [select id ,Orl_Units_Qty__c,Orl_Invoiced_Date__c,Orl_Gross_Value_Total__c,Orl_Sales_Person__c,CurrencyIsoCode,Advanced_Order__r.cgcloud__Order_Account__r.VAT_Number__c
                  ,Advanced_Order__r.cgcloud__Order_Account__r.Orl_Tax_Type__c,Advanced_Order__c,Advanced_Order__r.Name,Orl_Invoice_Ship_To__c,Orl_Invoice_No__c,Orl_Distributor__r.Name,
                   name,Advanced_Order__r.VAT__c,Advanced_Order__r.Gross_Value_After_Tax__c,Advanced_Order__r.cgcloud__Gross_Total_Value__c from Orl_invoice__c where id =: originalInvoice.Id ];

        Order = [Select Id,Name,cgcloud__Gross_Total_Value__c,VAT__c,Gross_Value_After_Tax__c,
        cgcloud__Order_Account__r.VAT_Number__c,cgcloud__Responsible__r.Name,cgcloud__Order_Account__r.Orl_Tax_Type__c,Orl_Regional_Manager_Discount__c,Orl_Area_Manager_Discount__c from cgcloud__Order__c
                 where Id =: Invoice.Advanced_Order__c];

        qrcodeurl = 'http://api.qrserver.com/v1/create-qr-code/?data=https://business-customization-1646--oreldev.sandbox.my.salesforce-sites.com?Id='+originalInvoice.Id;

        System.debug('Invoice=> '+this.Invoice);
        
        this.inputText = String.valueOf(Invoice.Orl_Gross_Value_Total__c);
        this.VATNO = Invoice.Advanced_Order__r.cgcloud__Order_Account__r.VAT_Number__c;
        this.TaxType = Invoice.Advanced_Order__r.cgcloud__Order_Account__r.Orl_Tax_Type__c;
        this.OrderlineItems = [Select Id,Name,cgcloud__Quantity__c,cgcloud__Discount__c,cgcloud__Product__c,cgcloud__Product__r.Name,cgcloud__Product__r.cgcloud__Product_Short_Code__c,
        cgcloud__Price__c,cgcloud__Value__c,cgcloud__Order_Item_Template__r.Name from cgcloud__Order_Item__c where cgcloud__Order__c =: Invoice.Advanced_Order__c];
        System.debug('OrderlineItem=> '+this.OrderlineItems);
    }
    
    public void generateQRCode() {
       
    }
   
}