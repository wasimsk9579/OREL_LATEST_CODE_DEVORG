// This class is used to associate the newly created product to the Standard pricebook & then to the Custom Pricebook
    //   above is achieving "ProductPartTrigger" After Insert
    
    public class ProductPricebookHandler {
    // Trigger to associate new products with the standard price book and set list price to 0
    // Trigger to associate new products with the standard and custom price books
    
    // Ids of the Standard and Custom Price Books (initialized in the constructor)
        String STANDARD_PRICEBOOK_ID;
        String CUSTOM_PRICEBOOK_ID;
    
        // Default List Price for new products
        static final Decimal DEFAULT_LIST_PRICE = 0;
    
        public  ProductPricebookHandler() {
            // Initialize Pricebook Ids by querying them by name
            STANDARD_PRICEBOOK_ID = getStandardPricebookId();
            CUSTOM_PRICEBOOK_ID = getCustomPricebookId();
        }
    
        // Helper method to get Standard Pricebook Id
        public  String getStandardPricebookId() {
            Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1];
            return standardPricebook.Id;
        }
    
        // Helper method to get Custom Pricebook Id
       public  String getCustomPricebookId() {
            Pricebook2 customPricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'SriLankan Currency PB' LIMIT 1];
            return customPricebook.Id;
        }
        public  void afterInsert(List<Product2> newProducts) {
            List<PricebookEntry> pricebookEntriesToInsert = new List<PricebookEntry>();
            List<PricebookEntry> pricebookEntriesToUpdate = new List<PricebookEntry>();
    
            // Iterate through the new products and create PricebookEntry records
            for (Product2 newProduct : newProducts) {
                  // Check if the "Product Bundle" checkbox is checked
                if (newProduct.Product_Bundle__c) {
                // Create PricebookEntry for Standard Price Book
                PricebookEntry standardPricebookEntry = new PricebookEntry(
                    Pricebook2Id = STANDARD_PRICEBOOK_ID,
                    Product2Id = newProduct.Id,
                    UnitPrice = DEFAULT_LIST_PRICE,
                    IsActive = false
                );
                pricebookEntriesToInsert.add(standardPricebookEntry);
    
                // Create PricebookEntry for Custom Price Book
                PricebookEntry customPricebookEntry = new PricebookEntry(
                    Pricebook2Id = CUSTOM_PRICEBOOK_ID,
                    Product2Id = newProduct.Id,
                    UnitPrice = DEFAULT_LIST_PRICE,
                    IsActive = true
                );
                pricebookEntriesToInsert.add(customPricebookEntry);
            }
         }
    
            // Insert the PricebookEntry records
            if (!pricebookEntriesToInsert.isEmpty()) {
                insert pricebookEntriesToInsert;
            }
    
            // Update existing entries in the Custom Price Book to mark them as active
            if (!pricebookEntriesToUpdate.isEmpty()) {
                update pricebookEntriesToUpdate;
            }
        }
        
        
        
     // after update is for the change in the Bundle price with Margin field
        public  void afterUpdate(List<Product2> newProducts, Map<Id, Product2> oldProductsMap) {
                 List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();
    
        // Map to store Product Ids and their updated Amounts
        Map<Id, Decimal> productAmountMap = new Map<Id, Decimal>();
    
       for (Product2 newProduct : newProducts) {
                // Check if the Bundle_Price__c field has been updated
               if (oldProductsMap.containsKey(newProduct.Id) &&
                   oldProductsMap.get(newProduct.Id).Bundle_Price__c != newProduct.Bundle_Price__c) {
    // Query for the associated OpportunityLineItems
                    List<OpportunityLineItem> opportunityLineItems = [
                       SELECT Id, Final_Price__c
                       FROM OpportunityLineItem
                        WHERE Product2Id = :newProduct.Id
                    ];
    
                    // Update the Final_Price__c field based on the new Bundle_Price__c
                    for (OpportunityLineItem oli : opportunityLineItems) {
                        oli.Final_Price__c = newProduct.Bundle_Price__c;
                        oliToUpdate.add(oli);
                  }
                }
           } 
    
            // Update the OpportunityLineItems
            if (!oliToUpdate.isEmpty()) {
                update oliToUpdate;
            }
        }
    
    }