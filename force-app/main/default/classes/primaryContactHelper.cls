public class primaryContactHelper {
  /* public static void handlePrimaryContact(List<Contact> contactList) {
         Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Contact> accountIdContactMap = new Map<Id,Contact>();

        for(Contact contactObj:contactList){
            if(contactObj.Is_primary_Contact__c==true && contactObj.AccountID!=null){               
                accountIdSet.add(contactObj.AccountID);
            }
        }
        if(accountIdSet!=null && accountIdSet.size()>0){            
            //Preparation of map accountIdContactMap for existing primary contact
            for(Contact contObj:[select id,Is_primary_Contact__c,AccountId from Contact 
                    where AccountId in:accountIdSet and Is_primary_Contact__c=true]){
                    accountIdContactMap.put(contObj.AccountId,contObj);
            }
            //validation starts
            for(Contact contactObj:contactList){
                if(contactObj.Is_primary_Contact__c==true && contactObj.AccountID!=null
                     && accountIdContactMap.get(contactObj.AccountId)!=null){
                        contactObj.addError('You can\'t create more than one primary contact.');
                    }                       
            }
        }
   }*/
    
     
    //sarting of logic to prevent user to create primary contact if there is any existing primary contact uner account
    public static void preventCreatePrimaryContactOnInsert(List<Contact> contactList){
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Contact> accountIdContactMap = new Map<Id,Contact>();

        for(Contact contactObj:contactList){
            if(contactObj.Is_primary_Contact__c	==true && contactObj.AccountID!=null){               
                accountIdSet.add(contactObj.AccountID);
            }
        }
        if(accountIdSet!=null && accountIdSet.size()>0){            
            //Preparation of map accountIdContactMap for existing primary contact
            for(Contact contObj:[select id,Is_primary_Contact__c	,AccountId from Contact 
                    where AccountId in:accountIdSet and Is_primary_Contact__c=true]){
                    accountIdContactMap.put(contObj.AccountId,contObj);
            }
            //validation starts
            for(Contact contactObj:contactList){
                if(contactObj.Is_primary_Contact__c==true && contactObj.AccountID!=null
                     && accountIdContactMap.get(contactObj.AccountId)!=null){
                        contactObj.addError('You can\'t create more than one primary contact.');
                    }                       
            }
        }

        
    }
    public static void preventPrimaryContactonUpdate(Map<Id,Contact> contactNewMap,Map<Id,Contact> contactOldMap){
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Contact> accountIdContactMap = new Map<Id,Contact>();
        for(Contact contactObj:contactNewMap.values()){
            if(contactNewMap.get(contactObj.id).Is_primary_Contact__c	!=contactOldMap.get(contactObj.Id).Is_primary_Contact__c	 
                && contactNewMap.get(contactObj.id).Is_primary_Contact__c	==true && contactNewMap.get(contactObj.id).AccountID!=null){               
                accountIdSet.add(contactNewMap.get(contactObj.id).AccountID);
            }
        }
        if(accountIdSet!=null && accountIdSet.size()>0){   
            //Preparation of map accountIdContactMap for existing primary contact
            for(Contact contObj:[select id,Is_primary_Contact__c	,AccountId from Contact 
                    where AccountId in:accountIdSet and Is_primary_Contact__c	=true]){
                    accountIdContactMap.put(contObj.AccountId,contObj);
            }
            //Validation
            for(Contact contactObj:contactNewMap.values()){
                if(contactNewMap.get(contactObj.id).Is_primary_Contact__c	!=contactOldMap.get(contactObj.Id).Is_primary_Contact__c	
                    && contactNewMap.get(contactObj.id).Is_primary_Contact__c	==true 
                    && contactNewMap.get(contactObj.id).AccountID!=null 
                    && accountIdContactMap.get(contactNewMap.get(contactObj.id).AccountID)!=null){               
                        contactObj.addError('You can\'t make more than one contact as primary.');
                }
            }


        }

    }
    
}