public with sharing class OrlInvoiceController {
    private final Orl_invoice__c originalInvoice;
    private List<cgcloud__Order_Item__c> orderItems;

    public OrlInvoiceController(ApexPages.StandardController stdController) {
        this.originalInvoice = (Orl_invoice__c)stdController.getRecord();
        System.debug('OriginalInvoice=> '+this.originalInvoice+' '+originalInvoice.Id);

        // Query the necessary fields including Orl_Order__c
        List<Orl_invoice__c> invoices = [SELECT Id, Orl_Order__c, Advanced_Order__c,Orl_Distributor__c, Orl_Invoice_Bill_To__Street__s, Orl_Invoice_Bill_To__City__s, Orl_Invoice_Bill_To__PostalCode__s, Orl_Invoice_Bill_To__CountryCode__s, Orl_Invoiced_Date__c, Orl_Sales_Person__c, Orl_Tel__c, Orl_Credit_Period__c, Orl_Units_Qty__c, Orl_Gross_Value_Total__c FROM Orl_invoice__c WHERE Id = :originalInvoice.Id LIMIT 1];
        
        if (!invoices.isEmpty()) {
            // Use a separate variable to store the queried invoice data
            Orl_invoice__c queriedInvoice = invoices[0];
            // Fetch related order items
            this.orderItems = getRelatedOrderItems(queriedInvoice);
        } else {
            this.orderItems = new List<cgcloud__Order_Item__c>();
        }
    }

    public List<cgcloud__Order_Item__c> getOrderItems() {
        return orderItems;
    }

    private List<cgcloud__Order_Item__c> getRelatedOrderItems(Orl_invoice__c queriedInvoice) {
        List<cgcloud__Order_Item__c> items = new List<cgcloud__Order_Item__c>();

        if (queriedInvoice.Advanced_Order__c != null) {
            // Assuming you have a relationship field named 'Advanced_Order__c' on Orl_invoice__c
            cgcloud__Order__c order = [SELECT Id FROM cgcloud__Order__c WHERE Id = :queriedInvoice.Advanced_Order__c LIMIT 1];

            if (order != null && order.Id != null) {
                // Fetch related order items
                items = [SELECT Id, cgcloud__Product__r.ProductCode, cgcloud__Product__r.Name, cgcloud__Price__c, cgcloud__Quantity__c, cgcloud__Value__c FROM cgcloud__Order_Item__c where cgcloud__Order__c  = :order.Id];
            }
        }

        return items;
    }
}