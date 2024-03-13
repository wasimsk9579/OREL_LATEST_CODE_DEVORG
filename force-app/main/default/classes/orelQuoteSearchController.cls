public class orelQuoteSearchController {
    
    public class ProductPartWrapper {
        @AuraEnabled public Id opportunityRecordId {get;set;}    
      }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Quote> searchQuotes(String quoteNumber) {
        return [SELECT Id, Name, QuoteNumber FROM Quote WHERE QuoteNumber = :quoteNumber LIMIT 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static  list<Product2> getQuoteLineItems(String quoteId) {
        List<QuoteLineItem> qlist =  [SELECT Id,product2Id, product2.name,Quantity, UnitPrice FROM QuoteLineItem WHERE QuoteId = :quoteId];
        system.debug(' The Qlist == > '+qlist);
        List<Product2> productList = new List<Product2>();
        for (QuoteLineItem qli : qlist) {
            Product2 product = [SELECT Id, Name, (SELECT Id,Part_Description__c,Dimensions__c,cgcloud__Quantity__c, cgcloud__Parent_Product__c, cgcloud__Parent_Product__r.Name FROM cgcloud__Product_Parts__r) FROM Product2 WHERE Id = :qli.Product2Id];
            system.debug(' The Product == > '+product);
            system.debug('Product Data: ' + product);
            if (product.cgcloud__Product_Parts__r != null) {
                for (cgcloud__Product_Part__c part : product.cgcloud__Product_Parts__r) {
                    system.debug('Product Part Data: ' + part);
                }
            }
            productList.add(product);
        }
        return productList;
    }
    
    
    @Auraenabled
    public static void handleAfterInsert(List<Id> parentIds , Id opportunityRecordId) {
        system.debug('handle insert invoking');
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        // Query for the Pricebook named 'srilankan PB'
        Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'SriLankan Currency PB' LIMIT 1];
        system.debug(' the pricebook = '+pricebook);
    
        for (Id parentId : parentIds) {
          Product2 product = [SELECT Id, Name, bundle_Price__c FROM Product2 WHERE Id = :parentId  LIMIT 1];
         //  Product2 product = [SELECT Id, Name FROM Product2 WHERE Id = :parentId  LIMIT 1];     
           
            if (product.Id != null) {
                // Query PricebookEntry based on Product2 and Pricebook2
                List<PricebookEntry> pricebookEntries = [
                    SELECT Id
                    FROM PricebookEntry
                    WHERE Product2Id = :parentId
                    AND Pricebook2Id = :pricebook.Id
                    LIMIT 1
                ];
                
                if (!pricebookEntries.isEmpty()) {
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.OpportunityId = opportunityRecordId;
                    system.debug(' opp iD = '+ oli.OpportunityId );
                    oli.PricebookEntryId = pricebookEntries[0].Id;
                    oli.Final_Price__c = product.bundle_Price__c;
                    oli.Quantity = 1; // You may adjust the quantity as needed
                    oli.UnitPrice = 1; // Set the unit price based on your business logic
                    opportunityLineItems.add(oli);
                } else {
                    System.debug('PricebookEntry not found for Product: ' + product.Name);
                }
            }
        }
        
        if (!opportunityLineItems.isEmpty()) {
            system.debug('Opp line items  = '+opportunityLineItems);
            insert opportunityLineItems;
            
        }
    }
}