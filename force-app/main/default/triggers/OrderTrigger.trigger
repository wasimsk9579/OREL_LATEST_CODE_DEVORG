trigger OrderTrigger on Order (after update) {
    for (Order updatedOrder : Trigger.new) {
        // Check if Return_Status__c is not null and has changed
        if (updatedOrder.Return_Status__c=='Approve')
            {
            returnflownotification.returnmethod(updatedOrder.Id);
        }
    }
}