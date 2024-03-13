trigger Rejectreturnnotificationtrigger on Order (after update){
for (Order updatedOrder : Trigger.new) {
         // Check if Return_Status__c is not null and has changedd
        if (updatedOrder.Return_Status__c=='Reject')
            {
           OrelReturnforreject.returnrejectmethod(updatedOrder.Id);
        }
    }
}