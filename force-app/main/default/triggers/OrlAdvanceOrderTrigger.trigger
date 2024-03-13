trigger OrlAdvanceOrderTrigger on cgcloud__Order__c (after update) {
      
    If(trigger.isUpdate && Trigger.isafter){
        OrlAdvancedOrderTriggerController.InventoryController(trigger.new, Trigger.oldMap);
        OrlAdvancedOrderTriggerController.SOInventoryController(trigger.new, Trigger.oldMap);
        OrlAdvancedOrderTriggerController.ROInventoryController(trigger.new, Trigger.oldMap);         
    }
}