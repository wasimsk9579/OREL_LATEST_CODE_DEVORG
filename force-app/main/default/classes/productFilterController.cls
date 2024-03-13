public class productFilterController {
    
      public class ProductPartWrapper {
         @AuraEnabled public String dimension {get;set;}
         @AuraEnabled public String PartDescription {get;set;}
          @AuraEnabled public String Id {get;set;}
          @AuraEnabled public Integer quantity {get;set;}
         @AuraEnabled public Decimal pricefactor {get;set;}
         @AuraEnabled public Decimal listprice {get;set;}
        @AuraEnabled public Id opportunityRecordId {get;set;}
          
      }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getFilteredProducts(String itemType, String brand, string pole,  string current) {
        // Query to fetch products based on the selected picklist values
        String queryString = 'SELECT Id, Name, Description, cgcloud__Description_1__c FROM Product2 WHERE';
        
        if (!String.isBlank(itemType)) {
            queryString += ' Item_Category__c = :itemType';
        }

        if (!String.isBlank(brand)) {
            if (!String.isBlank(itemType)) {
                queryString += ' AND';
            }
            queryString += ' Brands__c = :brand';
        }
        
         if (!String.isBlank(pole)) {
            if (!String.isBlank(itemType) || !String.isBlank(brand))  {
                queryString += ' AND';
            }
            queryString += ' Poles__c = :pole';
        }

        if (!String.isBlank(current)) {
            if (!String.isBlank(itemType) || !String.isBlank(brand) || !String.isBlank(pole) ) {
                queryString += ' AND';
            }
            queryString += ' Current__c = :current';
        }

        List<Product2> prod = Database.query(queryString);
        return prod;
    }
    
    @AuraEnabled
    public static List<cgcloud__Product_Part__c> createProductParts(Id parentId, List<Product2> selectedProducts) {
        List<cgcloud__Product_Part__c> productParts = new List<cgcloud__Product_Part__c>();
    
        for (Product2 selectedProduct : selectedProducts) {
            cgcloud__Product_Part__c part = new cgcloud__Product_Part__c();
            part.cgcloud__Parent_Product__c = parentId;
            part.cgcloud__Child_Product__c = selectedProduct.Id; 
            part.cgcloud__Valid_From__c = System.today();
            part.cgcloud__Valid_Thru__c = System.today().addDays(100);
            productParts.add(part);
        }
    
        if (!productParts.isEmpty()) {
            insert productParts;
        }
    
        // Query the inserted product parts and return them
        List<cgcloud__Product_Part__c> insertedProductParts = [SELECT Id, Name, cgcloud__Child_Product__c, Dimensions__c,List_price__c,Price_factor__c,cgcloud__Quantity__c, cgcloud__Child_Product__r.Name FROM cgcloud__Product_Part__c WHERE cgcloud__Parent_Product__c = :parentId];
        
        return insertedProductParts;
    }
    
    
    
     @AuraEnabled
    public static List<cgcloud__Product_Part__c> getInsertedProductParts(Id parentId) {
        System.debug('method Invoking');
        // Query inserted product parts based on the parent ID
    
    List<cgcloud__Product_Part__c> productParts = [SELECT Id, Name,Part_Description__c, cgcloud__Child_Product__c, Dimensions__c,List_price__c,Price_factor__c,cgcloud__Quantity__c, cgcloud__Child_Product__r.Name FROM cgcloud__Product_Part__c WHERE cgcloud__Parent_Product__c = :parentId];
    
    // Print the result to the debug logs
    System.debug('Product Parts: ' + productParts);

    // Return the result
    return productParts;
    }
    
    
    @AuraEnabled
 public static string deleteProductPart(Id productPartId) {
    System.debug('Deleting Product Parts with Ids: ' + productPartId);

    List<cgcloud__Product_Part__c> productPartsToDelete = [SELECT Id FROM cgcloud__Product_Part__c WHERE Id =:productPartId ];
     try{
          if (!productPartsToDelete.isEmpty()) {
        delete productPartsToDelete;
        
        System.debug('Deleted Product Parts: ' + productPartsToDelete);

    }
                 return 'Success';
     }
     catch(Exception e){
         System.debug('Error--'+e.getMessage());
         return 'Error';
     }
   


}
    
    
     @AuraEnabled
	public static List<cgcloud__Product_Part__c> UpdateProductParts(Id parentId, List<ProductPartWrapper> insertedProducts) {
    System.Debug('The updated Parts method Invoking---->' + parentId);
    System.Debug('The updated Parts method Invoking with selected items---->' + insertedProducts);
    List<cgcloud__Product_Part__c> productParts = new List<cgcloud__Product_Part__c>();
    
    for (ProductPartWrapper selectedProduct : insertedProducts) {
        system.debug('selectedProduct=====>'+selectedProduct.Id);
        cgcloud__Product_Part__c part = new cgcloud__Product_Part__c();
        part.Id = selectedProduct.Id; 
        part.cgcloud__Parent_Product__c = parentId;
        part.Dimensions__c = selectedProduct.dimension;
        part.Part_Description__c = selectedProduct.PartDescription;
        Part.Price_factor__c = selectedProduct.pricefactor;
        Part.cgcloud__Quantity__c = selectedProduct.quantity;
        part.List_price__c = selectedProduct.listprice;
        productParts.add(part);
    }
    
    if (!productParts.isEmpty()) {
        system.debug('Product part =' + productParts);
        update productParts;
        system.debug('updated product parts--->'+productParts);
    }
    return productParts;
}
    
     @Auraenabled
     public static void handleAfterInsert(Id parentId, Id opportunityRecordId) {
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
          system.debug(' Parent ID = '+parentId);
            system.debug(' Opportunity ID ID = '+opportunityRecordId);
          // Query for the Pricebook named 'SriLankan Currency PB'
        Pricebook2 pricebook = [SELECT Id, name FROM Pricebook2 WHERE Name = 'SriLankan Currency PB' LIMIT 1];
         system.debug(' the pricebook = '+pricebook);

    Product2 product = [SELECT Id, Name, bundle_Price__c  FROM Product2 WHERE Id = :parentId  LIMIT 1];
          System.debug('Product bundle price = : ' + product.bundle_Price__c);


            if (product.Id != null) {
                // Query PricebookEntry based on Product2 and Pricebook2
                List<PricebookEntry> pricebookEntries = [
                    SELECT Id
                    FROM PricebookEntry
                    WHERE Product2Id = :parentId
                    AND Pricebook2Id = :pricebook.Id
                    LIMIT 1
                ];
                 system.debug(' entries --> = '+pricebookEntries);

                if (!pricebookEntries.isEmpty()) {
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.OpportunityId = opportunityRecordId;
                    system.debug(' opp iD = '+ oli.OpportunityId );
                    oli.PricebookEntryId = pricebookEntries[0].Id;
                    oli.Final_Price__c = product.Bundle_Price__c;
                    oli.Quantity = 1; // You may adjust the quantity as needed
                    oli.UnitPrice = 1; // Set the unit price based on your business logic
                    opportunityLineItems.add(oli);
                } else {
                    System.debug('PricebookEntry not found for Product: ' + product.Name);
                }
            }
        

        if (!opportunityLineItems.isEmpty()) {
            system.debug('Opp line items  = '+opportunityLineItems);
            insert opportunityLineItems;
             system.debug('Opp line items inserted Suxccessfully--> ');
        }
    }
}