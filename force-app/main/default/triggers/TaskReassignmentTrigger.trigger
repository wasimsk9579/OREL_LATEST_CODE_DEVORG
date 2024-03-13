trigger TaskReassignmentTrigger on Opportunity (after update, after insert) {
    SendDrawingtoProductionTeamHelper.updateStatus();
    
    if(trigger.isAfter && trigger.isUpdate){
        //Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>([SELECT Id, OwnerId FROM Opportunity WHERE Id IN :Trigger.oldMap.keySet()]);
        //OpportunityAssignNotification.getNewOpportunities(Trigger.new, oldOppMap);
        DiscountHelper.getOpportunityLineItems(trigger.new, trigger.oldMap);
    }
}