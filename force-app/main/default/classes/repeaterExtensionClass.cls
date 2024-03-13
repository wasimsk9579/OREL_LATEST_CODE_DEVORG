public class repeaterExtensionClass {

      public String MstrId{GET;SET;}
    public List<QuoteLineItem> QuoteLineItems { get;  set; }
    public List<cgcloud__Product_Part__c> ProductsWith { get; set; }
        public List<Product2> Prod { get; set; }
    public String baseURL{GET;SET;}
     public Quote QuoteObj{GET;SET;}
     public String accowner { get; set; }
    
public repeaterExtensionClass(ApexPages.StandardController Controller){ 
      baseURL = URL.getSalesforceBaseUrl().toExternalForm(); 
    MstrId = controller.getId();  
    
       QuoteObj =  [SELECT Id, opportunityId,Name,  QuoteNumber,Subtotal,Tax,Tax_Type__c,VAT__c, Discount,CreatedBy.name,Grand_Total_price_with_VAT__c,Rep_Discount__c,Discounted_Price__c,Product_Price_With_Discount__c,
                    Vat_Amount__c,Products_Price_with_Quantity__c,Grand_total_price_with_VAT_Discount__c,Grand_Total_with_Qty_VAT_I_H__c,Brand_Change_Note__c,Quote_vise_Notes__c,Payment_Terms__c,Rep_Delivery__c,Rep_Validity__c,
                   Accountid, account.name, account.createdbyID,Account.Owner.name,Account.Owner.Phone,contact.name,
                          (SELECT Id,Product2Id, Quantity, UnitPrice, Product2.Name,PricebookEntry.Product2.Name,
                            Discount,LineNumber,TotalPrice,Electrical_Labour_Amount__c, Engraving_Tags_With_Legend_Plates_Amount__c, Instalation_Amount__c, Transport_Amount__c, Subtotal FROM Quotelineitems) 
                               FROM Quote WHERE Id = : MstrId];
        
       QuoteLineItems =[SELECT Id,Product2Id, Quantity, UnitPrice, Product2.Name,PricebookEntry.Product2.Name,
                             Discount,LineNumber,TotalPrice, Subtotal, Electrical_Labour_Amount__c, Engraving_Tags_With_Legend_Plates_Amount__c, Instalation_Amount__c, Transport_Amount__c 
                             FROM Quotelineitem  WHERE QuoteId = :MstrId];     
    
    List<Id> productIds = new List<Id>();
        for (QuoteLineItem lineItem : QuoteLineItems) {
            productIds.add(lineItem.Product2Id);
        }

// ProductsWith=[SELECT Id, name, cgcloud__Quantity__c,cgcloud__Parent_Product__r.name from cgcloud__Product_Part__c where cgcloud__Parent_Product__c =:productIds ];
    
    Prod = [Select Id, Name,Bundle_Price__c,Updated_Price_from_Line_item__c,Bundle_Price_with_Quantity__c,Bundle_Price_With_VAT__c,Bundle_Price_with_VAT_Quantity__c,Bundle_Quantity__c,Unit_Notes__c,
                (Select Id, name,cgcloud__Quantity__c,cgcloud__Child_Product__r.Name,Part_Description__c From cgcloud__Product_Parts__r  ) from Product2 where Id=: productIds];
    
   
 //   system.debug('the producyts are== '+ProductsWith);
    
    System.debug('The Original products are == '+Prod);
    
}
  
    
}