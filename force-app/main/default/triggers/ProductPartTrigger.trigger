/*   trigger ProductPartTrigger on Product2 (after insert , after Update) {
 if (Trigger.isInsert) {
     // THIS is to insert the bundle product to the standard & custom pricebook
        //ProductPricebookHandler.afterInsert(Trigger.new);
    }
   else if (Trigger.isUpdate) {
    // this is to update the bundle price with margin       
  //ProductPricebookHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}   */


trigger ProductPartTrigger on Product2 (after insert, after Update) {

// Check if the Product bundle field is true
    Set<Id> productIdsWithBundle = new Set<Id>();
    for (Product2 product : Trigger.new) {
        if (product.Product_Bundle__c) {
            productIdsWithBundle.add(product.Id);
        }
    }
    
    

if (!productIdsWithBundle.isEmpty()) {
    if (Trigger.isInsert) {
        // Create an instance of ProductPricebookHandler
        ProductPricebookHandler handler = new ProductPricebookHandler();
        
        // Call the non-static method afterInsert on the instance
        handler.afterInsert(Trigger.new);
    } else if (Trigger.isUpdate) {
        // Create an instance of ProductPricebookHandler
        ProductPricebookHandler handler = new ProductPricebookHandler();
        
        // Call the non-static method afterUpdate on the instance
        handler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}
}