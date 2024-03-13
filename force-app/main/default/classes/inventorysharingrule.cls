public class inventorysharingrule {
    public static void applySharingRule() {
        // Query only the necessary fields and filter as needed
       /* List<cgcloud__Inventory__c> retinvenlist = [SELECT Id, cgcloud__Account__c FROM cgcloud__Inventory__c];
        
        // Use a map to store account Ids and associated user Ids
        set<Id> accid = new set<Id>();
        List<User> guestUser;
        // Create inventory shares
        List<cgcloud__Inventory__Share> inventoryShares = new List<cgcloud__Inventory__Share>();
        for (cgcloud__Inventory__c inventory : retinvenlist) {
            accid.add(inventory.cgcloud__Account__c);
        }
        System.debug('accid' + accid.size());
        if(!accid.isEmpty()){
            guestUser = [SELECT Id, AccountId FROM User WHERE AccountId IN:accid];
        }else{
            System.debug('list empty');
        }
        for (cgcloud__Inventory__c inventory : [SELECT Id, cgcloud__Account__c FROM cgcloud__Inventory__c where cgcloud__Account__c=:guestUser[0].Id]) {
            cgcloud__Inventory__Share guestShare = new cgcloud__Inventory__Share();
            guestShare.ParentId = inventory.Id;
            guestShare.UserOrGroupId = guestUser[0].Id; // Replace with the actual Guest User Id
            guestShare.AccessLevel = 'Read'; // Adjust access level as needed
            inventoryShares.add(guestShare);
            System.debug('guestUser' + guestUser[0].id);
        }
        if (!inventoryShares.isEmpty()) {
            insert inventoryShares;
        }*/
    }
}