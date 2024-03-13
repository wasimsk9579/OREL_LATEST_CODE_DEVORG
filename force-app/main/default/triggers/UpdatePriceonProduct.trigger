trigger UpdatePriceonProduct on cgcloud__Product_Part__c (after insert, after update, after delete, after undelete) {
 Boolean isDelete = Trigger.isDelete;
    // this class is used to calculate the Final price of the Product part record after delete of any paroduct part
    ProductPartPriceUpdation.handle(Trigger.new, Trigger.oldMap, isDelete); 
}