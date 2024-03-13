public class orelinventoryupdate {
    Public static void SOInventoryController(List<Opportunitylineitem> newList){
        
         set<id> opportunityid = new set<id>();
         set<id> productid = new set<Id>();
         set<id> accid = new set<id>();
         set<id> inproductid = new set<id>();
    
         for(Opportunitylineitem opp :newList)
         {
             productid.add(opp.product2Id);
             accid.add(opp.Opportunity.AccountId);
             opportunityid.add(opp.OpportunityId);
             system.debug('productid'+productid);
             system.debug('accid'+accid);
             system.debug('opportunityid'+opportunityid);
             
             
         List<Account> comaccid = [select id,Name,Type__c from Account where Type__c='Company'];
            Set<id> accIdSet = new Set<Id>();
            for(Account acc : comaccid){
                accIdSet.add(acc.Id);
            }
             system.debug('opacid'+comaccid);
            
            list<cgcloud__Inventory__c> listinv = [select id,Name,cgcloud__Account__c,cgcloud__Balance__c,cgcloud__Product__c 
                                                   from cgcloud__Inventory__c 
                                                   where Orl_Inventory_type__c ='Company Inventory' 	
                                                   and cgcloud__Product__c=:productid and cgcloud__Account__c IN:accIdSet
                                                  ];
             if(listinv.size()< 1)
             {
                 opp.Adderror('there is no company inventory');
             }
            
         
         for(cgcloud__Inventory__c inv:listinv)
         {
             inproductid.add(inv.cgcloud__Product__c);
             system.debug('inventory product'+inproductid);
             
             if(inv.cgcloud__Balance__c == 0 || inv.cgcloud__Balance__c == null )
             {
                 opp.Adderror('Please add Company Primary Inventory for this product');
                 system.debug('result'+inv.cgcloud__Balance__c);
             }
             else if(opp.Quantity > inv.cgcloud__Balance__c)
             {
                 opp.Adderror('Quantity should not be greater than Company Inventory');
             }
         }
         }      
         }
}