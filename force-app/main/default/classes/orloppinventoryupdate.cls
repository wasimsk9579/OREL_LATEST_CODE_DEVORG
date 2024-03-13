public without sharing class orloppinventoryupdate {
   
    /************************************************************************************************************************************/
    //Method control the inventory for the Sales Order
       Public static void SOInventoryController(List<Opportunity> newList){
        
        Set<Id> oppoId = new Set<Id>();   //all opportunity ids
        Set<Id> oppaccid = new Set<Id>(); //distributors id
        Set<Id> ProductIds = new  Set<Id>();   // products id
        
        List<Opportunity> newListApproved = new List<Opportunity>();
        List<string> salesOrgsList = new List<string>();
        
        Map<id,List<OpportunityLineItem>> oppoIdToItemsMap = new Map<id,List<OpportunityLineItem>> ();
        Map<string, cgcloud__Inventory__c> accountAndProductToInventoryMap = new  Map<string, cgcloud__Inventory__c>();
        
       
        
        // Check for orders with the "Approved" status and Approval_Status__c equal to "Approved"
        for (Opportunity op : newList) {
         {
                    system.debug('got the id of Order SO>>>>>');
                    oppoId.add(op.Id);
                    oppaccid.add(op.AccountId);
                    newListApproved.add(op);
             system.debug('oppoId'+oppoId);
             system.debug('newListApproved'+newListApproved);
             
                }
        }
        
        //List of All order line item       
        For(OpportunityLineItem item : [SELECT Id, Name, Quantity, Product2Id,OpportunityId,Opportunity.AccountId
                                           FROM OpportunityLineItem
                                           WHERE OpportunityId IN :oppoId]){
                                               
                                               //Collecting Product Ids to fetch inventories
                                               ProductIds.add(item.Product2Id);
                                               
                                               If(oppoIdToItemsMap.containsKey(item.OpportunityId)){
                                                   oppoIdToItemsMap.get(item.OpportunityId).add(item);
                                               }Else{
                                                   oppoIdToItemsMap.put(item.OpportunityId,new List<OpportunityLineItem>{item});
                                               }
                                               
                                           }
        
        List<string> inventoryTypes = new List<string>{'Company Inventory','Hold Inventory'};
            
            //Get the account and product map to inventory
            accountAndProductToInventoryMap = GetInventoryMap(ProductIds, oppaccid, 'Primary Inventory', inventoryTypes);
        
        If(oppoIdToItemsMap.Keyset().size()>0){
            
            //Create inventory transactions
            CreateInventoryTransactions(accountAndProductToInventoryMap, newListApproved, oppoIdToItemsMap);
        }
        
        
        
    }
    
    /*******************************************************************************************************************************************************************/    
    //Method to get the map of account+product to Inventory
    
    Public static Map<string, cgcloud__Inventory__c> GetInventoryMap(Set<Id> ProductIds, Set<Id> oppaccid, string InventoryTemplateType, List<string> inventoryTypes){
        
        system.debug('inside inventory>>');
        
        Map<string, cgcloud__Inventory__c> accountAndProductToInventoryMap = new Map<string, cgcloud__Inventory__c>();
        RecordType rctype = [SELECT Id FROM RecordType WHERE sObjectType = 'cgcloud__Inventory_Control_Template__c' AND DeveloperName = 'Inventory' LIMIT 1];
        system.debug('recordtype>>'+ rctype);
        system.debug('ProductIds>>'+ ProductIds);
        system.debug('distributorIds>>'+ oppaccid);
        
        //Fetch the Company Account 
        List<Account> CompanyAccounts = [SELECT Id from Account WHERE Type__c = 'Company' LIMIT 1];
        IF(CompanyAccounts.size() > 0){
            oppaccid.add(CompanyAccounts[0].Id);
        }
        //system.debug('CompanyAccount>>'+ CompanyAccount);
        
        // Query the Inventory record based on the product Id and additional Id
        List<cgcloud__Inventory__c> inventoryList = [SELECT Id, cgcloud__Account__c, cgcloud__Account__r.Name, cgcloud__Product__c, cgcloud__Product__r.Name,Inventory_Control_Template_Type__c,Orl_Inventory_type__c, cgcloud__Balance__c, Name
                                                     FROM cgcloud__Inventory__c
                                                     WHERE cgcloud__Product__c IN :ProductIds
                                                     AND cgcloud__Account__c IN :oppaccid 
                                                     AND Orl_Inventory_type__c IN :inventoryTypes
                                                     /*  AND (Orl_Inventory_type__c = 'Van Inventory' 
OR Orl_Inventory_type__c = 'Company Inventory' 
OR Orl_Inventory_type__c = 'Distributor Inventory')*/
                                                     AND Inventory_Control_Template_Type__c = :InventoryTemplateType
                                                     AND cgcloud__Inventory_Template__r.RecordTypeId = :rctype.Id
                                                     AND cgcloud__Invalid__c = false
                                                     AND cgcloud__Phase__c = 'Active'];
        
        For(cgcloud__Inventory__c inventory : inventoryList){
            string str = (string)inventory.cgcloud__Account__c+(string)inventory.cgcloud__Product__c+inventory.Orl_Inventory_type__c;
            If(!accountAndProductToInventoryMap.containsKey(str)){
                accountAndProductToInventoryMap.Put(str,inventory);
                system.debug('inventory added>>'+ accountAndProductToInventoryMap.get(str));
            }            
        } 
        
        Return accountAndProductToInventoryMap;
        
    }
    
    
    /*********************************************************************************************************************************************************************/
    //Method to create the inventory transactions
    
    Public static void CreateInventoryTransactions(Map<string, cgcloud__Inventory__c> accountAndProductToInventoryMap, List<Opportunity> newList1, Map<id,List<OpportunityLineItem>> orderIdToItemsMap){
        
        
        List<cgcloud__Inventory_Transaction__c> inventoryListToUpdate = new List<cgcloud__Inventory_Transaction__c>();
        
        Map<string,Id> typeTotemplateIdMap = new Map<string,Id>();
        
        //Inventory Transaction
        List<cgcloud__Inventory_Transaction_Template__c> cgtList = [select Id,cgcloud__Transaction_Control__c,cgcloud__Transaction_Type__c  from cgcloud__Inventory_Transaction_Template__c 
                                                                    WHERE (cgcloud__Transaction_Control__c = 'Withdraw' 
                                                                           AND cgcloud__Transaction_Type__c = 'Withdrawal') 
                                                                    OR (cgcloud__Transaction_Control__c = 'Add' 
                                                                        AND cgcloud__Transaction_Type__c = 'Addition')];
        
        For(cgcloud__Inventory_Transaction_Template__c tmp : cgtList){
            typeTotemplateIdMap.put(tmp.cgcloud__Transaction_Control__c,tmp.Id);
        }
        
        
        //Fetch the Company Account 
        Account CompanyAccount = [SELECT Id from Account WHERE Type__c = 'Company' LIMIT 1];
        
        
        for (Opportunity updatedOrder : newList1) {
            
            If(orderIdToItemsMap.get(updatedOrder.Id) != null){
                
                
                For(OpportunityLineItem item : orderIdToItemsMap.get(updatedOrder.Id))
                {
                    
                    
                    //For PO-SO orders START
                
                            //Check the inventory
                            If(accountAndProductToInventoryMap.get((string)CompanyAccount.Id+(string)item.Product2Id+'Company Inventory') != null 
                               && accountAndProductToInventoryMap.get((string)item.Opportunity.AccountId+(string)item.Product2Id+'Distributor Inventory') != Null){
                                   
                                   
                                   cgcloud__Inventory_Transaction__c inventoryTransaction = GenerateInventoryTransaction(item, 
                                                                                                                         typeTotemplateIdMap.get('Withdraw'), 
                                                                                                                         accountAndProductToInventoryMap.get((string)CompanyAccount.Id+(string)item.Product2Id+'Company Inventory'), 
                                                                                                                         'substract', 'Sales Order by distributor', updatedOrder);
                                   cgcloud__Inventory_Transaction__c inventoryTransaction1 = GenerateInventoryTransaction(item, 
                                                                                                                          typeTotemplateIdMap.get('Add'), 
                                                                                                                          accountAndProductToInventoryMap.get((string)item.Opportunity.AccountId+(string)item.Product2Id+'Distributor Inventory'), 
                                                                                                                          'add', 'Sales Order by distributor', updatedOrder);   
                                   
                                   
                                   inventoryListToUpdate.addAll(new List<cgcloud__Inventory_Transaction__c>{inventoryTransaction,inventoryTransaction1});
                               }
                            
                            //Inventory is not present
                            else If(accountAndProductToInventoryMap.get((string)CompanyAccount.Id+(string)item.Product2Id+'Company Inventory') == null){
                                updatedOrder.addError('Please add Company Primary Inventory for '+item.Product2.Name);
                            }else If(accountAndProductToInventoryMap.get((string)item.Opportunity.AccountId+(string)item.Product2Id+'Distributor Inventory') == null){
                                updatedOrder.addError('Please add Distributor Primary Inventory for '+item.Product2.Name);
                            }
                            
                        }
                    }
                    //For PO-SO orders END      
                }
            
        
        
        For(cgcloud__Inventory_Transaction__c inv: inventoryListToUpdate)
      {
    

            system.debug('inventoryListToUpdate>>'+inv);
        
        Insert inventoryListToUpdate;
        
    }
}
    
    /**********************************************************************************************************************************************************************************/
    //method to create inventory
    
    Public static cgcloud__Inventory_Transaction__c GenerateInventoryTransaction(OpportunityLineItem item, string templateId, cgcloud__Inventory__c inventory, string actionType, string transactionStatus, Opportunity updatedOrder){
        
        system.debug('product>>'+item);
        
        cgcloud__Inventory_Transaction__c inventoryTransaction = new cgcloud__Inventory_Transaction__c();
        
        inventoryTransaction.cgcloud__Inventory__c = inventory.Id;
        
        If(actionType == 'substract'){
            
            If(item.Quantity > inventory.cgcloud__Balance__c){
                updatedOrder.addError('Insufficient balance in the inventory '+inventory.Name+' for product '+item.Product2.Name);
            }
            
            inventoryTransaction.cgcloud__Amount__c = -item.Quantity;
        }else{
            inventoryTransaction.cgcloud__Amount__c = item.Quantity;
        }
        
      //  inventoryTransaction.OpportunityLineItem = item.Id;
        inventoryTransaction.cgcloud__Order_Document__c = item.OpportunityId;
        inventoryTransaction.cgcloud__Inventory_Transaction_Template__c = templateId;
        If(transactionStatus != null && transactionStatus != '')
            inventoryTransaction.Orl_Order_transaction_status__c = transactionStatus;        
        Return inventoryTransaction;
        
    }
    
    public class InsufficientBalanceException extends Exception {}
}