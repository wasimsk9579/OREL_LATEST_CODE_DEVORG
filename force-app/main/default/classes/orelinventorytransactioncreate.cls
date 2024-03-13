public class orelinventorytransactioncreate {
    // validation before creating opportunity line item to show an errors
    
    Public static void SOInventoryController(List<Opportunitylineitem> newList){
        set<id> opporid = new set<id>();
        set<id> productid = new set<Id>();
        
        for(Opportunitylineitem opp :newList)
        {
            productid.add(opp.product2Id);
            opporid.add(opp.OpportunityId);
         
        }
        Opportunity op=[Select id,RecordTypeId,RecordType.Name from Opportunity Where Id=:opporid];
     if(op.RecordType.Name =='Purchase')
     {
            List<Account> comaccid = [select id,Name,Type__c from Account where Type__c='Company'];
            Set<id> accIdSet = new Set<Id>();
            for(Account acc : comaccid){
                accIdSet.add(acc.Id);
                  }            
            list<cgcloud__Inventory__c> listinv = [select id,Name,cgcloud__Account__c,cgcloud__Balance__c,cgcloud__Product__c,Orl_Inventory_type__c,Inventory_Control_Template_Type__c	
                                                   from cgcloud__Inventory__c 
                                                   where Orl_Inventory_type__c ='Company Inventory'AND Orl_Inventory_type__c  != null and Inventory_Control_Template_Type__c='Primary Inventory'
                                                   and cgcloud__Product__c=:productid and cgcloud__Account__c IN:accIdSet
                                                  ];
         Map<Id, Boolean> productMatchMap = new Map<Id, Boolean>();
    for (Id prductId : productid) {
        productMatchMap.put(prductId, false); // Assume all products don't match initially
    }
    
    for(cgcloud__Inventory__c inv : listinv) {
        productMatchMap.put(inv.cgcloud__Product__c, true); // Set to true if a match is found
    }
    
   for(OpportunityLineItem opp : newList) {
        if (!productMatchMap.containsKey(opp.Product2Id) || !productMatchMap.get(opp.Product2Id)) {
            opp.addError('Product doesnt consists of company inventory');
        }
    }
        
         for(cgcloud__Inventory__c inv:listinv){
            for(Opportunitylineitem opp : newList){
                if(inv.cgcloud__Balance__c == 0 || inv.cgcloud__Balance__c == null )
                {
                    opp.Adderror('This item is out of stock and cannot be processed at the moment');
                }
                else if(opp.Quantity > inv.cgcloud__Balance__c)
                {
                    opp.Adderror('Quantity should not be greater than Company Inventory');
                }
                else if(opp.Product2Id != inv.cgcloud__Product__c)
                {
                    system.debug('resultt');
                }
            
       
                
        }      
    }
     }
    }
    
 //*****************************************************************************************************************************// 
    // Code to create inventory transaction after inserting opportunity line item.
    public static void createInventoryTransaction(List<OpportunityLineItem> newList){
        
        set<id> opporid = new set<id>();
        set<id> productid = new set<Id>();
        list<cgcloud__Inventory_Transaction__c> invtransaction = new list<cgcloud__Inventory_Transaction__c>(); 
        
        //Inventory withdraw Transaction
        List<cgcloud__Inventory_Transaction_Template__c> cgtList = [select Id,cgcloud__Transaction_Control__c,cgcloud__Transaction_Type__c  from cgcloud__Inventory_Transaction_Template__c 
                                                                    WHERE (cgcloud__Transaction_Control__c = 'Withdraw' 
                                                                           AND cgcloud__Transaction_Type__c = 'Withdrawal')];
        List<Account> comaccid = [select id,Name,Type__c from Account where Type__c='Company'];
        Set<id> accIdSet = new Set<Id>();
        for(Account acc : comaccid){
            accIdSet.add(acc.Id);
        }
        system.debug('opacid'+comaccid);
        
        for(Opportunitylineitem opp :newList){
            productid.add(opp.product2Id);
            opporid.add(opp.OpportunityId);
        } 
         Opportunity op=[Select id,RecordTypeId,RecordType.Name from Opportunity Where Id=:opporid];
     if(op.RecordType.Name =='Purchase')
     {
        list<cgcloud__Inventory__c> listinv = [select id,Name,cgcloud__Account__c,cgcloud__Balance__c,cgcloud__Product__c,Inventory_Control_Template_Type__c
                                               from cgcloud__Inventory__c 
                                               where Orl_Inventory_type__c ='Company Inventory' and Inventory_Control_Template_Type__c='Primary Inventory' 	
                                               and cgcloud__Product__c=:productid and cgcloud__Account__c IN:accIdSet
                                              ];
        
        for(cgcloud__Inventory__c inv:listinv){
            for(Opportunitylineitem opp : newList){
                if(inv.cgcloud__Product__c==opp.Product2Id)
                {
                    cgcloud__Inventory_Transaction__c inventoryTransaction = new cgcloud__Inventory_Transaction__c();
                    inventoryTransaction.cgcloud__Inventory__c=inv.Id;
                    inventoryTransaction.cgcloud__Inventory_Transaction_Template__c=cgtList[0].Id;
                    inventoryTransaction.cgcloud__Amount__c = -opp.Quantity;
                    invtransaction.add(inventoryTransaction);   
                }
            }
        }        
        
        //Inventory add Transaction
        List<cgcloud__Inventory_Transaction_Template__c> cgtList1 = [select Id,cgcloud__Transaction_Control__c,cgcloud__Transaction_Type__c  from cgcloud__Inventory_Transaction_Template__c 
                                                                     WHERE (cgcloud__Transaction_Control__c = 'Add' 
                                                                            AND cgcloud__Transaction_Type__c = 'Addition')];
        
        
        list<cgcloud__Inventory__c> listinv1 = [select id,Name,cgcloud__Account__c,cgcloud__Balance__c,cgcloud__Product__c,Inventory_Control_Template_Type__c from cgcloud__Inventory__c
                                                where  Orl_Inventory_type__c ='Hold Inventory' and Inventory_Control_Template_Type__c='Primary Inventory'
                                                and cgcloud__Product__c=:productid and cgcloud__Account__c=:accIdSet];
        for(cgcloud__Inventory__c inven:listinv1){
            for(Opportunitylineitem opp : newList){
                if(inven.cgcloud__Product__c==opp.Product2Id)
                {
                    cgcloud__Inventory_Transaction__c inventoryaddTransaction = new cgcloud__Inventory_Transaction__c();
                    inventoryaddTransaction.cgcloud__Inventory__c=inven.Id;
                    inventoryaddTransaction.cgcloud__Inventory_Transaction_Template__c=cgtList1[0].Id;
                    inventoryaddTransaction.cgcloud__Amount__c =opp.Quantity;
                    invtransaction.add(inventoryaddTransaction);
                }
            }
        }  
        System.debug('invtransaction=' + invtransaction + '\ninvtransaction SIZE= ' + invtransaction.size());       
        insert invtransaction;
    }
    }
    
    // after update opportunitylineitem create company nad hold inventory 
//****************************************************************************************************************************//   
public static void SOInventoryupdate(List<OpportunityLineItem> newList, List<OpportunityLineItem> oldList) {
    Map<Id, Decimal> quantityChanges = new Map<Id, Decimal>();
    Map<Id, Decimal> hquantityChanges = new Map<Id, Decimal>();
    Set<Id> productIds = new Set<Id>();
      set<id> opporid = new set<id>();

    // Populate productIds and calculate quantity changes
    for (OpportunityLineItem newLine : newList) {
        productIds.add(newLine.Product2Id);
         opporid.add(newLine.OpportunityId);
        Decimal oldQuantity = 0;
        for (OpportunityLineItem oldLine : oldList) {
            if (newLine.Id == oldLine.Id) {
                oldQuantity = oldLine.Quantity;
                break;
            }
        }
        Decimal quantityChange = newLine.Quantity - oldQuantity;
        Decimal hquantityChange = oldQuantity- newLine.Quantity;
        if (oldQuantity < newLine.Quantity) {
            quantityChanges.put(newLine.Product2Id, quantityChange);
        } else if (oldQuantity > newLine.Quantity) {
            hquantityChanges.put(newLine.Product2Id, hquantityChange);
        }
    }
     Opportunity op=[Select id,RecordTypeId,RecordType.Name from Opportunity Where Id=:opporid];
    if(op.RecordType.Name =='Purchase')
     {

    List<cgcloud__Inventory_Transaction__c> transactions = new List<cgcloud__Inventory_Transaction__c>();

    // Query Inventory Transaction Templates for "Add" and "Withdraw"
    List<cgcloud__Inventory_Transaction_Template__c> addTemplates = [SELECT Id
                                                                     FROM cgcloud__Inventory_Transaction_Template__c
                                                                     WHERE cgcloud__Transaction_Control__c = 'Add'
                                                                     AND cgcloud__Transaction_Type__c = 'Addition'];

    List<cgcloud__Inventory_Transaction_Template__c> withdrawTemplates = [SELECT Id
                                                                          FROM cgcloud__Inventory_Transaction_Template__c
                                                                          WHERE cgcloud__Transaction_Control__c = 'Withdraw'
                                                                          AND cgcloud__Transaction_Type__c = 'Withdrawal'];

     List<Account> comaccid = [select id,Name,Type__c from Account where Type__c='Company'];
        Set<id> accIdSet = new Set<Id>();
        for(Account acc : comaccid){
            accIdSet.add(acc.Id);
        }
    // Query Inventories for both types
    Map<Id, cgcloud__Inventory__c> companyInventoryMap = new Map<Id, cgcloud__Inventory__c>();
    Map<Id, cgcloud__Inventory__c> holdInventoryMap = new Map<Id, cgcloud__Inventory__c>();
    for (cgcloud__Inventory__c inv : [SELECT Id, cgcloud__Account__c, cgcloud__Balance__c, cgcloud__Product__c, Orl_Inventory_type__c,Inventory_Control_Template_Type__c
                                      FROM cgcloud__Inventory__c
                                      WHERE cgcloud__Product__c IN :productIds AND cgcloud__Account__c=:accIdSet AND Inventory_Control_Template_Type__c='Primary Inventory'
                                      AND (Orl_Inventory_type__c = 'Company Inventory' OR Orl_Inventory_type__c = 'Hold Inventory')]) {
        if (inv.Orl_Inventory_type__c == 'Company Inventory') {
            companyInventoryMap.put(inv.cgcloud__Product__c, inv);
        } else if (inv.Orl_Inventory_type__c == 'Hold Inventory') {
            holdInventoryMap.put(inv.cgcloud__Product__c, inv);
        }
    }

    // Create transactions for Quantity changes
    for (Id productId : quantityChanges.keySet()) {
        Decimal quantityChange = quantityChanges.get(productId);
        cgcloud__Inventory__c companyInventory = companyInventoryMap.get(productId);
        cgcloud__Inventory__c holdInventory = holdInventoryMap.get(productId);

        // Create transaction for Company Inventory
        if (companyInventory != null) {
            cgcloud__Inventory_Transaction__c companyTransaction = new cgcloud__Inventory_Transaction__c();
            companyTransaction.cgcloud__Inventory__c = companyInventory.Id;
            companyTransaction.cgcloud__Amount__c = -quantityChange;
            companyTransaction.cgcloud__Inventory_Transaction_Template__c = withdrawTemplates[0].Id;
       
            transactions.add(companyTransaction);
        }

        // Create transaction for Hold Inventory
        if (holdInventory != null) {
            cgcloud__Inventory_Transaction__c holdTransaction = new cgcloud__Inventory_Transaction__c();
            holdTransaction.cgcloud__Inventory__c = holdInventory.Id;
            holdTransaction.cgcloud__Amount__c = quantityChange;
            holdTransaction.cgcloud__Inventory_Transaction_Template__c = addTemplates[0].Id;
        
            transactions.add(holdTransaction);
        }
    }

    // Create transactions for Hold Quantity changes
    for (Id productId : hquantityChanges.keySet()) {
        Decimal hquantityChange = hquantityChanges.get(productId);
        cgcloud__Inventory__c companyInventory = companyInventoryMap.get(productId);
        cgcloud__Inventory__c holdInventory = holdInventoryMap.get(productId);

        // Create transaction for Company Inventory
        if (companyInventory != null) {
            cgcloud__Inventory_Transaction__c companyTransaction = new cgcloud__Inventory_Transaction__c();
            companyTransaction.cgcloud__Inventory__c = companyInventory.Id;
            companyTransaction.cgcloud__Amount__c = hquantityChange;
            companyTransaction.cgcloud__Inventory_Transaction_Template__c = addTemplates[0].Id;
   
            transactions.add(companyTransaction);
        }

        // Create transaction for Hold Inventory
        if (holdInventory != null) {
            cgcloud__Inventory_Transaction__c holdTransaction = new cgcloud__Inventory_Transaction__c();
            holdTransaction.cgcloud__Inventory__c = holdInventory.Id;
            holdTransaction.cgcloud__Amount__c = -hquantityChange;
            holdTransaction.cgcloud__Inventory_Transaction_Template__c = withdrawTemplates[0].Id;
      
            transactions.add(holdTransaction);
        }
    }

    // Insert transactions
    if (!transactions.isEmpty()) {
        insert transactions;
    }
}
}

 //***************************************************************************************************************************//
    
    // validation before updating opportunity line item to shows an errors    
    public static void SOInventorycheck(List<Opportunitylineitem> newList,List<Opportunitylineitem> oldList) {
        
        Set<Id> productid = new Set<Id>();
         set<id> opporid = new set<id>();
        for(Opportunitylineitem nopp : newList) {
            for(Opportunitylineitem oopp : oldList)
            {
                productid.add(nopp.product2Id);
                 opporid.add(nopp.OpportunityId);
                system.debug('nopp.Quantity'+nopp.Quantity);
                system.debug('oopp.Quantity'+oopp.Quantity);
                Opportunity op=[Select id,RecordTypeId,RecordType.Name from Opportunity Where Id=:opporid];
                if(op.RecordType.Name =='Purchase')
                 {
                
                List<cgcloud__Inventory_Transaction_Template__c> cgtList = [select Id,cgcloud__Transaction_Control__c,cgcloud__Transaction_Type__c  from cgcloud__Inventory_Transaction_Template__c 
                                                                            WHERE (cgcloud__Transaction_Control__c = 'Withdraw' 
                                                                                   AND cgcloud__Transaction_Type__c = 'Withdrawal')];
                List<Account> comaccid = [select id,Name,Type__c from Account where Type__c='Company'];
                Set<id> accIdSet = new Set<Id>();
                for(Account acc : comaccid){
                    accIdSet.add(acc.Id);
                }
                system.debug('opacid'+comaccid);
                
                list<cgcloud__Inventory__c> listinv = [select id,Name,cgcloud__Account__c,cgcloud__Balance__c,cgcloud__Product__c,Inventory_Control_Template_Type__c
                                                       from cgcloud__Inventory__c 
                                                       where Orl_Inventory_type__c ='Company Inventory' and Inventory_Control_Template_Type__c='Primary Inventory'	
                                                       and cgcloud__Product__c=:productid and cgcloud__Account__c IN:accIdSet
                                                      ];
                for(cgcloud__Inventory__c inv:listinv)
                {             
                    if(inv.cgcloud__Balance__c == 0 || inv.cgcloud__Balance__c == null )
                    {
                        nopp.Adderror('Please add Company Primary Inventory for this product');
                        system.debug('result'+inv.cgcloud__Balance__c);
                    }
                }
                
                if((nopp.Quantity-oopp.Quantity) > listinv[0].cgcloud__Balance__c)
                {
                    
                    nopp.adderror('Quantity should not be greater than Company Inventory');
                }             
            }
        }
    }
    }
 //***************************************************************************************************************************//   
    // validation after deleting opportunity line item to create inventory transaction
    
    public static void deleteinventorytransaction(List<OpportunityLineItem> dellist)
    {
        set<id> productid = new set<Id>();
         set<id> opporid = new set<id>();
        list<cgcloud__Inventory_Transaction__c> invtransaction = new list<cgcloud__Inventory_Transaction__c>(); 
         for(Opportunitylineitem opp :dellist){
            productid.add(opp.product2Id);
            opporid.add(opp.OpportunityId); 
        } 
        Opportunity op=[Select id,RecordTypeId,RecordType.Name from Opportunity Where Id=:opporid];
                if(op.RecordType.Name =='Purchase')
                 {
        //Inventory add Transaction
  List<cgcloud__Inventory_Transaction_Template__c> cgtList1 = [select Id,cgcloud__Transaction_Control__c,cgcloud__Transaction_Type__c 
                                                               from cgcloud__Inventory_Transaction_Template__c 
                                                                         WHERE (cgcloud__Transaction_Control__c = 'Add' 
                                                                                AND cgcloud__Transaction_Type__c = 'Addition')];            
            
        List<Account> comaccid = [select id,Name,Type__c from Account where Type__c='Company'];
        Set<id> accIdSet = new Set<Id>();
        for(Account acc : comaccid){
            accIdSet.add(acc.Id);
        }
        system.debug('opacid'+comaccid);
        
       
        list<cgcloud__Inventory__c> listinv = [select id,Name,cgcloud__Account__c,cgcloud__Balance__c,cgcloud__Product__c,Inventory_Control_Template_Type__c
                                               from cgcloud__Inventory__c 
                                               where Orl_Inventory_type__c ='Company Inventory' and Inventory_Control_Template_Type__c='Primary Inventory'
                                               and cgcloud__Product__c=:productid and cgcloud__Account__c IN:accIdSet
                                              ];
        
        for(cgcloud__Inventory__c inv:listinv){
            for(Opportunitylineitem opp : dellist){
                if(inv.cgcloud__Product__c==opp.Product2Id)
                {
                    cgcloud__Inventory_Transaction__c inventoryTransaction = new cgcloud__Inventory_Transaction__c();
                    inventoryTransaction.cgcloud__Inventory__c=inv.Id;
                    inventoryTransaction.cgcloud__Inventory_Transaction_Template__c=cgtList1[0].Id;
                    inventoryTransaction.cgcloud__Amount__c = opp.Quantity;
                    invtransaction.add(inventoryTransaction);   
                }
            }
        }        
        
               //Inventory withdraw Transaction
            List<cgcloud__Inventory_Transaction_Template__c> cgtList = [select Id,cgcloud__Transaction_Control__c,cgcloud__Transaction_Type__c  from cgcloud__Inventory_Transaction_Template__c 
                                                                        WHERE (cgcloud__Transaction_Control__c = 'Withdraw' 
                                                                               AND cgcloud__Transaction_Type__c = 'Withdrawal')];
        
        
        list<cgcloud__Inventory__c> listinv1 = [select id,Name,cgcloud__Account__c,cgcloud__Balance__c,cgcloud__Product__c,Inventory_Control_Template_Type__c from cgcloud__Inventory__c
                                                where  Orl_Inventory_type__c ='Hold Inventory' and Inventory_Control_Template_Type__c='Primary Inventory'
                                                and cgcloud__Product__c=:productid and cgcloud__Account__c=:accIdSet];
        for(cgcloud__Inventory__c inven:listinv1){
            for(Opportunitylineitem opp : dellist){
                if(inven.cgcloud__Product__c==opp.Product2Id)
                {
                    cgcloud__Inventory_Transaction__c inventoryaddTransaction = new cgcloud__Inventory_Transaction__c();
                    inventoryaddTransaction.cgcloud__Inventory__c=inven.Id;
                    inventoryaddTransaction.cgcloud__Inventory_Transaction_Template__c=cgtList[0].Id;
                    inventoryaddTransaction.cgcloud__Amount__c =-opp.Quantity;
                    invtransaction.add(inventoryaddTransaction);
                }
            }
        }  
        System.debug('invtransaction=' + invtransaction + '\ninvtransaction SIZE= ' + invtransaction.size());       
        insert invtransaction;
    }
    }

//**************************************************************************************************************************//    
    // when opportunity closed lost creating inventory transaction
    public static void oppcloselost(List<Opportunity> newoppList,List<Opportunity> oldList)
    {
         set<id> productid = new set<Id>();
        list<cgcloud__Inventory_Transaction__c> invtransaction = new list<cgcloud__Inventory_Transaction__c>(); 
        
        //Inventory add Transaction
  List<cgcloud__Inventory_Transaction_Template__c> cgtList1 = [select Id,cgcloud__Transaction_Control__c,cgcloud__Transaction_Type__c 
                                                               from cgcloud__Inventory_Transaction_Template__c 
                                                                         WHERE (cgcloud__Transaction_Control__c = 'Add' 
                                                                                AND cgcloud__Transaction_Type__c = 'Addition')];            
            
        List<Account> comaccid = [select id,Name,Type__c from Account where Type__c='Company'];
        Set<id> accIdSet = new Set<Id>();
        for(Account acc : comaccid){
            accIdSet.add(acc.Id);
        }
        for(Opportunity oppo:oldList)
        {
            for(Opportunity oppn:newoppList)
            {
                Opportunity op=[Select id,RecordTypeId,RecordType.Name from Opportunity Where Id=:oppo.Id];
                system.debug('recordtype'+op.RecordType.Name);
                if(op.RecordType.Name =='Purchase')
                 {
                
                if(oppo.StageName == 'Qualification' && oppn.StageName == 'Closed Lost'){
               
                {
                    list<Opportunitylineitem> newList =[Select Id,Name,Quantity,Product2Id from Opportunitylineitem where OpportunityId =:oppo.Id];
                    system.debug('newList'+newList);
                 
                    for(Opportunitylineitem opp :newList)
                    {
                        productid.add(opp.product2Id);
                        system.debug('productid'+productid);   
        } 
        list<cgcloud__Inventory__c> listinv = [select id,Name,cgcloud__Account__c,cgcloud__Balance__c,cgcloud__Product__c,Inventory_Control_Template_Type__c
                                               from cgcloud__Inventory__c 
                                               where Orl_Inventory_type__c ='Company Inventory' and Inventory_Control_Template_Type__c='Primary Inventory'	
                                               and cgcloud__Product__c=:productid and cgcloud__Account__c IN:accIdSet
                                              ];
        
        for(cgcloud__Inventory__c inv:listinv){
            for(Opportunitylineitem opp : newList){
                if(inv.cgcloud__Product__c==opp.Product2Id)
                {
                    cgcloud__Inventory_Transaction__c inventoryTransaction = new cgcloud__Inventory_Transaction__c();
                    inventoryTransaction.cgcloud__Inventory__c=inv.Id;
                    inventoryTransaction.cgcloud__Inventory_Transaction_Template__c=cgtList1[0].Id;
                    inventoryTransaction.cgcloud__Amount__c = opp.Quantity;
                    invtransaction.add(inventoryTransaction);   
                }
            }
        }       
                    
                     //Inventory withdraw Transaction
            List<cgcloud__Inventory_Transaction_Template__c> cgtList = [select Id,cgcloud__Transaction_Control__c,cgcloud__Transaction_Type__c  from cgcloud__Inventory_Transaction_Template__c 
                                                                        WHERE (cgcloud__Transaction_Control__c = 'Withdraw' 
                                                                               AND cgcloud__Transaction_Type__c = 'Withdrawal')];
        
        
        list<cgcloud__Inventory__c> listinv1 = [select id,Name,cgcloud__Account__c,Inventory_Control_Template_Type__c,cgcloud__Balance__c,cgcloud__Product__c from cgcloud__Inventory__c
                                                where  Orl_Inventory_type__c ='Hold Inventory' and Inventory_Control_Template_Type__c='Primary Inventory'
                                                and cgcloud__Product__c=:productid and cgcloud__Account__c=:accIdSet];
        for(cgcloud__Inventory__c inven:listinv1){
            for(Opportunitylineitem opp : newList){
                if(inven.cgcloud__Product__c==opp.Product2Id)
                {
                    cgcloud__Inventory_Transaction__c inventoryaddTransaction = new cgcloud__Inventory_Transaction__c();
                    inventoryaddTransaction.cgcloud__Inventory__c=inven.Id;
                    inventoryaddTransaction.cgcloud__Inventory_Transaction_Template__c=cgtList[0].Id;
                    inventoryaddTransaction.cgcloud__Amount__c =-opp.Quantity;
                    invtransaction.add(inventoryaddTransaction);
                }
            }
        }  
        System.debug('invtransaction=' + invtransaction + '\ninvtransaction SIZE= ' + invtransaction.size());       
        insert invtransaction;
    }
            }  
        }                   
        }   }
}
    
 //***************************************************************************************************************************// 

    public static void itemInclusion(List<OpportunityLineItem> opitemlist)
    {
        set<id> oplid = new set<id>();
        for(OpportunityLineItem itemid:opitemlist)
        {
            oplid.add(itemid.id);
        }    
        List<String> testReturn = new List<String>(); 
        testReturn.add('testing');
        
        List<OpportunityLineItem> ItemList =[Select Id, Quantity,UnitPrice, Product2Id, OpportunityId,FOC_Added__c from OpportunityLineItem where Id IN :oplid AND FOC_Added__c = false];
        Set<Id> prodIds = new Set<Id>();
        List<FOC_Condition__c> focList = new List<FOC_Condition__c>();
        Map<Id,Map<Decimal, Decimal>> focMap = new Map<Id,Map<Decimal, Decimal>>();
        List<OpportunityLineItem> itemInsertList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> itemUpdateList = new List<OpportunityLineItem>();
       // cgcloud__Order_Item_Template__c itemTemplate = [SELECT Id, Name FROM cgcloud__Order_Item_Template__c where Name = 'Free Item' LIMIT 1];
        if(ItemList!=null && ItemList.size()>0)
        {
            for(OpportunityLineItem cod : ItemList)
            {
                prodIds.add(cod.Product2Id);
            }
        }
        focList = [Select Id, Product__c, Base_Quantity__c, FOC_Quantity__c from FOC_Condition__c where Product__c IN :prodIds ORDER BY Base_Quantity__c asc];
        for(FOC_Condition__c foc: focList)
        {
            Map<Decimal, Decimal> focEntry = new Map<Decimal, Decimal>();
            if(focMap.containsKey(foc.Product__c))
            {
				focEntry = focMap.get(foc.Product__c);
                focEntry.put(foc.Base_Quantity__c, foc.FOC_Quantity__c);
                focMap.put(foc.Product__c, focEntry);
            }else{
                focEntry.put(foc.Base_Quantity__c, foc.FOC_Quantity__c);  
                focMap.put(foc.Product__c, focEntry);
            }
        }
        System.debug('focMap::'+focMap);
        if(ItemList!=null && ItemList.size()>0)
        {
            System.debug('first If::');
            for(OpportunityLineItem orderItem : ItemList)
            {
                System.debug('items_for::');
                OpportunityLineItem newOrderItem = new OpportunityLineItem();
                if(focMap.containsKey(orderItem.Product2Id))
                {
                    System.debug('second if::');
                    List<Decimal> keyList = sortList(focMap.get(orderItem.Product2Id)); //5 10
                    System.debug('keyList::'+keyList);
                    if(orderItem.Quantity>0 && orderItem.Quantity>=keyList.get(0) &&focMap.get(orderItem.Product2Id).keySet().size()>0)
                    { 
                        System.debug('third if::');
                        Decimal thisIt = 0;
                        //List<> iterKeys = focMap.get(orderItem.cgcloud__Product__c).values(); 
                        
                        for(Decimal key : keyList)
                        {
                            thisIt++;
                            if(key>orderItem.Quantity)
                            {
                                break;                           
                            }
                        }                   
                        newOrderItem.Product2Id = orderItem.Product2Id;
                        newOrderItem.OpportunityId = orderItem.OpportunityId;
                        Decimal Index = (Decimal)keyList.get((Integer)thisIt-2);
                        newOrderItem.Quantity = focMap.get(orderItem.Product2Id).get(index);
                        newOrderItem.FOC_Product__c = true;
                        newOrderItem.UnitPrice =0;
                        itemInsertList.add(newOrderItem);
                        System.debug('itemInsertList::'+itemInsertList);
                        orderItem.FOC_Added__c = true;
                        itemUpdateList.add(orderItem);             
                    }
                }
            }
        }
        
        if(itemInsertList!=null && itemInsertList.size()>0)
            insert itemInsertList;
        if(itemUpdateList!=null && itemUpdateList.size()>0)
            update itemUpdateList;
    
    }
    
    public static List<Decimal> sortList(Map<Decimal, Decimal> deciMap)
    {
        Set<Decimal> recSet = deciMap.keySet();
        List<Decimal> unsortList = new List<Decimal>();
        //Set<Decimal> recDecSet = (Set<Decimal>)JSON.deserialize(JSON.serialize(recSet), Set<Decimal>.class);
        if(unsortList.size()>1)
            unSortList.addAll(recSet);
        else
        {
            unSortList.addAll(recSet);
            unSortList.add(unSortList.get(0)+1);
        }
        return unSortList; 
    }
    
//****************************************************************************************************************************//
    public static void deletfoc(list<OpportunityLineItem> oplineitem)
    {    
        set<id> proid = new set<id>();
        set<id> opportuid = new set<id>();
        for(OpportunityLineItem  opline:oplineitem)
        {
             
            if(opline.FOC_Added__c==true)
            {
                 proid.add(opline.Product2Id);
                  opportuid.add(opline.OpportunityId);
                 system.debug('opline'+opline.id);
            }
           
           
        }
        list<OpportunityLineItem> oplinefoc=[Select Id, Quantity,UnitPrice, Product2Id, OpportunityId,FOC_Product__c from OpportunityLineItem where FOC_Product__c = true and OpportunityId=:opportuid and Product2Id=:proid];
                   set<id> proidfoc=new set<id>();                        
        {
            for(OpportunityLineItem op:oplinefoc)
            {
                proidfoc.add(op.Product2Id);
                system.debug('opline'+op.id);
            }
        } 
        if(oplinefoc.size()>0)
        {
            system.debug('oplinefoc'+oplinefoc[0].Id);
            delete oplinefoc;
        }
                                             
    }
    
 //***********************************************************************************************************************//
      
public static void focupdate(list<OpportunityLineItem> oplineitem)
{
        List<FOC_Condition__c> focList = new List<FOC_Condition__c>();
        set<id>oplineid = new set<id>();
        set<id> proid = new set<id>();
        set<id> opportuid = new set<id>();
     List<OpportunityLineItem> itemsToUpdate = new List<OpportunityLineItem>();
        for(OpportunityLineItem  opline:oplineitem)
        {
             
            if(opline.FOC_Added__c==true)
            {
                 proid.add(opline.Product2Id);
                  opportuid.add(opline.OpportunityId);
                  oplineid.add(opline.Id);
                
            }
        }
    
     list<OpportunityLineItem> updopline=[Select Id, Quantity,UnitPrice, Product2Id,FOC_Added__c from OpportunityLineItem where id=:oplineid];
    
     focList = [Select Id, Product__c, Base_Quantity__c, FOC_Quantity__c from FOC_Condition__c where Product__c IN :proid ORDER BY Base_Quantity__c asc];
     for(FOC_Condition__c foc:focList)
     {
         for(OpportunityLineItem opl:oplineitem)
         {
             if(foc.Product__c == opl.Product2Id && opl.Quantity < foc.Base_Quantity__c)
             {
                 list<OpportunityLineItem> oplinefoc=[Select Id, Quantity,UnitPrice, Product2Id, OpportunityId,FOC_Product__c from OpportunityLineItem where FOC_Product__c = true and OpportunityId=:opportuid and Product2Id=:proid];
                
                 if(oplinefoc.size()>0)
        {
                        delete oplinefoc;
                    System.debug('Deleted oplinefoc records');
                    
                    // Update the FOC_Added__c field to false for oplineitem records
                    for (OpportunityLineItem focItem : updopline) {
                        focItem.FOC_Added__c = false;
                    }

                    // Update the original OpportunityLineItem records
                    update updopline;
                    System.debug('Updated oplineitem records with FOC_Added__c = false');
                }
            }
        }
             }
         }
    }