public class OpportunityAssignNotification {
    public static void getNewOpportunities(List<Opportunity> opData, Map<Id, Opportunity> oldOppMap){
        for(Opportunity newop : opData){
            Opportunity oldop = oldOppMap.get(newop.Id);
            
            if(oldop != null && newop.OwnerId != oldop.OwnerId){
                System.debug('newop.OwnerId is==' + newop.OwnerId);
                System.debug('old opp owner=====' + oldop.OwnerId);
                
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                List<CustomNotificationType> cNotifyList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'A_opportunity_is_assigned_to_you' LIMIT 1];
                
                if(!cNotifyList.isEmpty()){
                    notification.setNotificationTypeId(cNotifyList[0].Id);
                    notification.setBody('An opportunity ' + newop.Name + ' is assigned to you.');
                    //notification.setTitle('A quote is approved');
                    notification.setTargetId(newop.Id);
                    
                    Set<String> recipientIds = new Set<String>{newop.OwnerId};
                    notification.send(recipientIds);
                }
            }
        }
    } 
}