trigger orelinventorytransactioncreatetrigger on OpportunityLineItem (before insert,after insert,after update,before update,after delete) {
   if(Trigger.isbefore){
        if(trigger.isinsert){
            orelinventorytransactioncreate.SOInventoryController(trigger.new);        
        }if(trigger.isupdate){
            orelinventorytransactioncreate.SOInventorycheck(trigger.new,trigger.old);
        }
    } 
    
    if(Trigger.isafter){
        if(trigger.isinsert){
            orelinventorytransactioncreate.createInventoryTransaction(trigger.new);
            orelinventorytransactioncreate.itemInclusion(trigger.new);
           // OpportunityLineItemFOC.createFOCLineItems(trigger.new);
        }
        if(trigger.isupdate){
            orelinventorytransactioncreate.SOInventoryupdate(trigger.new,trigger.old);
             orelinventorytransactioncreate.itemInclusion(trigger.new);
            orelinventorytransactioncreate.focupdate(trigger.new);
        }if(Trigger.isdelete){
            orelinventorytransactioncreate.deleteinventorytransaction(trigger.old);
            orelinventorytransactioncreate.deletfoc(trigger.old);
            
        }
    }
 
}