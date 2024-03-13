trigger TaskReassignEmailTrigger on Task (after insert, after update) {
    List<Task> newTasks = Trigger.new;
    
    if(trigger.isAfter && trigger.isInsert){
        
        TaskCreationNotificationHelper.sendTaskCreationNotification(newTasks);
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        TaskReassignEmailHelper.sendTaskAssignmentNotification(newTasks);
        TaskReassignEmailHelper.taskReassignmentNotificationtoPT(newTasks);
    }
    
}