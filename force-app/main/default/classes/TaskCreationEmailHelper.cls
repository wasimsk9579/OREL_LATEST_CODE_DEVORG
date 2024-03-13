public class TaskCreationEmailHelper {
    public static void createTaskOnOpportunity(List<Quote> newQuotes, Map<Id, Quote> oldMap) {
        List<Task> newTasks = new List<Task>();
        Set<Id> opportunityIds = new Set<Id>();
        
        for (Quote newQuote : newQuotes) {
            Quote oldQuote = oldMap.get(newQuote.Id);
            
            // Check if the status changed to "Accepted"
            if (newQuote.Status == 'Accepted' && (oldQuote == null || oldQuote.Status != 'Accepted') && newQuote.Orl_Opportunity_record_type__c=='Repeater') {
                system.debug(' quote record tyep==>' +newQuote.Orl_Opportunity_record_type__c);
                opportunityIds.add(newQuote.OpportunityId);
            }
        }
        
        // Create tasks for each Opportunity
        for (Id opportunityId : opportunityIds) {
            Id oppId = opportunityId;
            //Opportunity opList = [SELECT id, OwnerId from Opportunity where id =: oppId];
            Profile pf =[Select Id, name from profile where name='Project Head Profile'];
            User us = [Select id, name, profile.name from user where profile.Id = :pf.Id limit 1];
            Id ownId = us.Id;
            Task newTask = new Task();
            newTask.WhatId = opportunityId;
            newTask.OwnerId = ownId;
            newTask.Status = 'Open';
            newTask.Priority = 'Normal';
            newTask.Subject = 'Create Drawings';
            newTask.Description = 'Request for drawings from the customer.';
            newTasks.add(newTask);
        }
        
        // Insert the new tasks
        if (!newTasks.isEmpty()) {
            insert newTasks;
            
            // Send email alert to the Opportunity owner
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            for (Task task : newTasks) {
                if (task.OwnerId != null) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTargetObjectId(task.OwnerId);
                    email.setSaveAsActivity(false);
                    email.setSubject('New Task Created ID: ' + task.Id);
                    email.setPlainTextBody('Dear Opportunity Owner,\n\n'+
                                           'I trust this message finds you well.\n'+
                                           'A new task has been created with the following details and please start working on drawings.\n\n' +
                                           'Task ID: ' + task.Id + '\n' + 
                                           'Opportunity Name: ' + task.What.Name + '\n' +
                                           'Thanks & Regards \n'+
                                           'Customer');
                    emails.add(email);
                }
            }
            
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        }
    }
}