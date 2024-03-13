public without sharing class OrlAdvancedOrderTriggerController {
    
    /************************************************************************************************************************************/
    //Method to create line items for the Bundled Orders 
    
    @future
    public static void updateLineItems(String liststring){
        System.debug('came inside the updateLineItems>' + liststring);
        
        Id itemTemplateId;
        
        if (String.isNotBlank(liststring)) {
            Set<Id> orderIds = new Set<Id>();
            List<object> obList = (List<object>)JSON.deserializeUntyped(liststring);
            For(object ob : obList){
                orderIds.add((string)ob);
            }
            System.debug('the order ids are>>'+orderIds);
            if (orderIds.isEmpty()) {
                System.debug('No valid OrderIds provided.');
                return;
            }
            
            Set<Id> distributorIds = new Set<Id>();
            Set<Id> relatedOrderIds = new Set<Id>();
            
            List<cgcloud__Order_Item__c> itemsToInsert = new List<cgcloud__Order_Item__c>();
            
            Map<Id, Map<String, Decimal>> parentOrderIdToItemsQtyMap = new Map<Id, Map<String, Decimal>>();
            Map<Id, Map<String, Id>> parentOrderIdToItemIdMap = new Map<Id, Map<String, Id>>();
            Map<Id, Map<String, Decimal>> orderAndProductWithQtyMap = new Map<Id, Map<String, Decimal>>();
            
            cgcloud__Order_Template__c returnTemplate;
            try {
                returnTemplate = [SELECT Id 
                                  FROM cgcloud__Order_Template__c 
                                  WHERE Name ='Return' 
                                  AND cgcloud__Active__c = true
                                  LIMIT 1];
            } catch (QueryException e) {
                System.debug('Error querying Order Template: ' + e.getMessage());
                throw new InsufficientBalanceException(e.getMessage());
                //return;
            }
            
            List<cgcloud__Order__c> newList;
            try {
                newList = [SELECT Id, cgcloud__Order_Account__c, Bundle__c,
                           (SELECT Id 
                            FROM Advanced_Orders__r), 
                           (SELECT Id, cgcloud__Product__c, cgcloud__Quantity__c,cgcloud__Order_Item_Template__c 
                            FROM cgcloud__Order_Items__r) 
                           FROM cgcloud__Order__c 
                           WHERE Id IN : orderIds];
            } catch (QueryException e) {
                System.debug('Error querying Orders: ' + e.getMessage());
                throw new InsufficientBalanceException(e.getMessage());
                // return;
            }
            
            System.debug('the parent Orders are>>' + newList);
            
            // Check whether there are any existing orders items in bundled order
            for (cgcloud__Order__c order : newList) {
                
                for (cgcloud__Order__c relatedOrder : order.Advanced_Orders__r) {
                    relatedOrderIds.add(relatedOrder.Id);
                }
                
                system.debug('related the order Ids are>>'+order.Advanced_Orders__r);
                if (!parentOrderIdToItemsQtyMap.containsKey(order.Id) && order.cgcloud__Order_Items__r != null && !order.cgcloud__Order_Items__r.isEmpty()) {
                    
                    Map<String, Id> productWithItemIdMap = new Map<String, Id>();
                    
                    for (cgcloud__Order_Item__c item : order.cgcloud__Order_Items__r) {
                        itemTemplateId = item.cgcloud__Order_Item_Template__c;
                        
                        if (!productWithItemIdMap.containsKey(item.cgcloud__Product__c)) {
                            productWithItemIdMap.put(item.cgcloud__Product__c, item.Id);
                        } 
                    }
                    
                    if (productWithItemIdMap != null) {
                        parentOrderIdToItemIdMap.put(order.Id, productWithItemIdMap);
                    }
                }
            }
            
            // Fetch all the related orders
            List<cgcloud__Order__c> relatedOrderList;
            try {
                relatedOrderList = [SELECT Id, cgcloud__Order_Account__c,Orl_Parent_Return_Order_Id__c,
                                    (SELECT Id, cgcloud__Product__c, cgcloud__Quantity__c 
                                     FROM cgcloud__Order_Items__r) 
                                    FROM cgcloud__Order__c WHERE Id IN :relatedOrderIds];
            } catch (QueryException e) {
                throw new InsufficientBalanceException(e.getMessage());
            }
            
            // Check whether orders exist
            for (cgcloud__Order__c order : relatedOrderList) {
                Map<String, Decimal> productWithQtyMap = new Map<String, Decimal>();
                
                if (orderAndProductWithQtyMap.containsKey(order.Orl_Parent_Return_Order_Id__c)) {
                    productWithQtyMap = orderAndProductWithQtyMap.get(order.Orl_Parent_Return_Order_Id__c);
                }
                
                if (order.cgcloud__Order_Items__r != null) {
                    for (cgcloud__Order_Item__c item : order.cgcloud__Order_Items__r) {
                        distributorIds.add(order.cgcloud__Order_Account__c);
                        if (!productWithQtyMap.containsKey((String)item.cgcloud__Product__c)) {
                            productWithQtyMap.put((String)item.cgcloud__Product__c, item.cgcloud__Quantity__c);
                        } else {
                            productWithQtyMap.put((String)item.cgcloud__Product__c, item.cgcloud__Quantity__c + productWithQtyMap.get((String)item.cgcloud__Product__c));
                        }
                    }
                }
                
                If(productWithQtyMap != null)
                    orderAndProductWithQtyMap.put(order.Orl_Parent_Return_Order_Id__c, productWithQtyMap);
            }
            
            // Check whether orders exist
            for (String parentOrderId : orderAndProductWithQtyMap.keySet()) {
                
                
                if (orderAndProductWithQtyMap.get(parentOrderId) != null) {
                    for (String productId : orderAndProductWithQtyMap.get(parentOrderId).keySet()) {
                        cgcloud__Order_Item__c item = new cgcloud__Order_Item__c();
                        item.cgcloud__Order__c = parentOrderId;
                        item.cgcloud__Quantity__c = 0;
                        item.cgcloud__Product__c = productId;
                        If(itemTemplateId != null || itemTemplateId != ''){
                            item.cgcloud__Order_Item_Template__c = itemTemplateId;
                        }
                        
                        
                        if (parentOrderIdToItemIdMap != null && parentOrderIdToItemIdMap.get(parentOrderId) != null) {
                            if (parentOrderIdToItemIdMap.get(parentOrderId).keySet().contains(productId)) {
                                item.Id = parentOrderIdToItemIdMap.get(parentOrderId).get(productId);
                            }
                        }
                        
                        if (orderAndProductWithQtyMap != null && orderAndProductWithQtyMap.get(parentOrderId) != null) {
                            if (orderAndProductWithQtyMap.get(parentOrderId).containsKey(productId)) {
                                item.cgcloud__Quantity__c = item.cgcloud__Quantity__c + orderAndProductWithQtyMap.get(parentOrderId).get(productId);
                            }
                        }
                        itemsToInsert.add(item);
                    }
                }
                
                
            }
            
            //Upsert the line items
            if (!itemsToInsert.isEmpty()) {
                Database.UpsertResult[] upsertResults = Database.upsert(itemsToInsert, false); // Set the second parameter to false to allow partial success
                
                // Debugging success results
                for (Integer i = 0; i < upsertResults.size(); i++) {
                    if (upsertResults[i].isSuccess()) {
                        System.debug('Upsert success for record with Id: ' + upsertResults[i].getId());
                    }
                }
                
                // Debugging failure results
                for (Integer i = 0; i < upsertResults.size(); i++) {
                    if (!upsertResults[i].isSuccess()) {
                        System.debug('Upsert failure for record at index ' + i + ' with errors: ' + upsertResults[i].getErrors());
                    }
                }
            }
        }
    }
    
    
    
    /************************************************************************************************************************************/
    //Controller for return orders
    
    Public static void InventoryController(List<cgcloud__Order__c> newList, Map<Id, cgcloud__Order__c> oldMap){
        
        system.debug('InventoryController is running');
        
        Set<Id> approvedOrderIds = new Set<Id>();
        Set<Id> distributorIdsApproved = new Set<Id>();
        Set<Id> ProductIds = new  Set<Id>();
        Set<Id> OrderIds = new Set<Id>();
        
        
        List<cgcloud__Order__c> newListApproved = new List<cgcloud__Order__c>();
        List<string> salesOrgsList = new List<string>();
        
        Map<id,List<cgcloud__Order_Item__c>> orderIdToItemsMap = new Map<id,List<cgcloud__Order_Item__c>> ();
        Map<string, cgcloud__Inventory__c> accountAndProductToInventoryMap = new  Map<string, cgcloud__Inventory__c>();
        
        cgcloud__Order_Template__c returnTemplate = [SELECT Id 
                                                     FROM cgcloud__Order_Template__c 
                                                     WHERE Name ='Return' 
                                                     AND cgcloud__Active__c = true
                                                     LIMIT 1];
        
        
        // Check for orders with the "Approved" status and Approval_Status__c equal to "Approved"
        for (cgcloud__Order__c updatedOrder : newList) {
            if ( oldMap.get(updatedOrder.Id).Orl_Return_Status__c != updatedOrder.Orl_Return_Status__c 
                && updatedOrder.Return_Order_Type__c == 'Replacement' 
                && updatedOrder.Bundle__c == false
                &&  (updatedOrder.Orl_Return_Status__c == 'Approved'  
                     || (updatedOrder.Orl_Return_Status__c == 'Received at distributor W/H' && updatedOrder.Bundle__c != true)
                     || (updatedOrder.Orl_Return_Status__c == 'Sent to Orel W/H' && updatedOrder.Bundle__c != true)
                     || (updatedOrder.Orl_Return_Status__c == 'Received at Orel W/H' && updatedOrder.Bundle__c != true))
                && updatedOrder.cgcloud__Order_Template__c == returnTemplate.Id) {
                    
                    system.debug('Order processedd>>'+updatedOrder);
                    salesOrgsList.add(updatedOrder.cgcloud__Order_Template__c);
                    approvedOrderIds.add(updatedOrder.Id);
                    distributorIdsApproved.add(updatedOrder.cgcloud__Order_Account__c);
                    newListApproved.add(updatedOrder);
                }
            //creatinglist incase of Bundling
            if ( updatedOrder.Orl_Parent_Return_Order_Id__c != null
                && oldMap.get(updatedOrder.Id).Orl_Parent_Return_Order_Id__c != updatedOrder.Orl_Parent_Return_Order_Id__c 
                && updatedOrder.Orl_Return_Status__c == 'Sent to Orel W/H' && updatedOrder.Bundle__c != true
               ){
                   
                   OrderIds.add(updatedOrder.Orl_Parent_Return_Order_Id__c);
               }
        }
        
        //calling future method incase of Bundling
        If(OrderIds.size() > 0){
            system.debug('Bundled orders id are>>'+OrderIds);
            updateLineItems(JSON.Serialize(OrderIds));
        }
        
        
        //List of All order line item       
        For(cgcloud__Order_Item__c item : [SELECT Id, Name, cgcloud__Quantity__c, cgcloud__Product__c, cgcloud__Product__r.Name, cgcloud__Order__r.cgcloud__Order_Account__c, cgcloud__Order__r.cgcloud__Order_Account__r.Name, cgcloud__Order__r.cgcloud__Order_Template__r.Name, cgcloud__Order__r.cgcloud__Visit__r.AccountId
                                           FROM cgcloud__Order_Item__c
                                           WHERE cgcloud__Order__c IN :approvedOrderIds]){
                                               
                                               //Collecting Product Ids to fetch inventories
                                               ProductIds.add(item.cgcloud__Product__c);
                                               
                                               If(orderIdToItemsMap.containsKey(item.cgcloud__Order__c)){
                                                   orderIdToItemsMap.get(item.cgcloud__Order__c).add(item);
                                               }Else{
                                                   orderIdToItemsMap.put(item.cgcloud__Order__c,new List<cgcloud__Order_Item__c>{item});
                                               }
                                               
                                           }
        
        List<string> inventoryTypes = new List<string>{'Van Inventory','Company Inventory','Distributor Inventory'};
            
            //Get the account and product map to inventory
            accountAndProductToInventoryMap = GetInventoryMap(ProductIds, distributorIdsApproved, 'Return Inventory', inventoryTypes);
        If(orderIdToItemsMap.keyset().size()>0){
            //Create inventory transactions
            CreateInventoryTransactions(accountAndProductToInventoryMap, newListApproved, orderIdToItemsMap);
        }
        
        
    }
    
    
    /************************************************************************************************************************************/
    //Method control the inventory for the Sales Order
    
    Public static void SOInventoryController(List<cgcloud__Order__c> newList, Map<Id, cgcloud__Order__c> oldMap){
        
        Set<Id> approvedOrderIds = new Set<Id>();
        Set<Id> distributorIdsApproved = new Set<Id>();
        Set<Id> ProductIds = new  Set<Id>();
        
        List<cgcloud__Order__c> newListApproved = new List<cgcloud__Order__c>();
        List<string> salesOrgsList = new List<string>();
        
        Map<id,List<cgcloud__Order_Item__c>> orderIdToItemsMap = new Map<id,List<cgcloud__Order_Item__c>> ();
        Map<string, cgcloud__Inventory__c> accountAndProductToInventoryMap = new  Map<string, cgcloud__Inventory__c>();
        
        cgcloud__Order_Template__c salesTemplate = [SELECT Id 
                                                    FROM cgcloud__Order_Template__c 
                                                    WHERE Name ='Sales Template' 
                                                    AND cgcloud__Active__c = true
                                                    LIMIT 1];
        
        // Check for orders with the "Approved" status and Approval_Status__c equal to "Approved"
        for (cgcloud__Order__c updatedOrder : newList) {
            if ( oldMap.get(updatedOrder.Id).GRNGenerated__c != updatedOrder.GRNGenerated__c 
                && updatedOrder.GRNGenerated__c == 'Completed' 
                && updatedOrder.cgcloud__Order_Template__c == salesTemplate.Id) {
                    system.debug('got the id of Order SO>>>>>');
                    salesOrgsList.add(updatedOrder.cgcloud__Order_Template__c);
                    approvedOrderIds.add(updatedOrder.Id);
                    distributorIdsApproved.add(updatedOrder.cgcloud__Order_Account__c);
                    newListApproved.add(updatedOrder);
                }
        }
        
        //List of All order line item       
        For(cgcloud__Order_Item__c item : [SELECT Id, Name, cgcloud__Quantity__c, cgcloud__Product__c, cgcloud__Product__r.Name, cgcloud__Order__r.cgcloud__Order_Account__c, cgcloud__Order__r.cgcloud__Order_Account__r.Name, 
                                           cgcloud__Order__r.cgcloud__Order_Template__r.Name, cgcloud__Order__r.cgcloud__Visit__r.AccountId, cgcloud__Order__r.GRNGenerated__c
                                           FROM cgcloud__Order_Item__c
                                           WHERE cgcloud__Order__c IN :approvedOrderIds]){
                                               
                                               //Collecting Product Ids to fetch inventories
                                               ProductIds.add(item.cgcloud__Product__c);
                                               
                                               If(orderIdToItemsMap.containsKey(item.cgcloud__Order__c)){
                                                   orderIdToItemsMap.get(item.cgcloud__Order__c).add(item);
                                               }Else{
                                                   orderIdToItemsMap.put(item.cgcloud__Order__c,new List<cgcloud__Order_Item__c>{item});
                                               }
                                               
                                           }
        
        List<string> inventoryTypes = new List<string>{'Hold Inventory','Distributor Inventory'};
            
            //Get the account and product map to inventory
            accountAndProductToInventoryMap = GetInventoryMap(ProductIds, distributorIdsApproved, 'Primary Inventory', inventoryTypes);
        
        If(orderIdToItemsMap.Keyset().size()>0){
            
            //Create inventory transactions
            CreateInventoryTransactions(accountAndProductToInventoryMap, newListApproved, orderIdToItemsMap);
        }
        
        
        
    }
    
    
    
    /************************************************************************************************************************************/
    //Method control the inventory for the Retailer Order
    
    Public static void ROInventoryController(List<cgcloud__Order__c> newList, Map<Id, cgcloud__Order__c> oldMap){
        
        Set<Id> approvedOrderIds = new Set<Id>();
        Set<Id> distributorIdsApproved = new Set<Id>();
        Set<Id> ProductIds = new  Set<Id>();
        
        List<cgcloud__Order__c> newListApproved = new List<cgcloud__Order__c>();
        List<string> salesOrgsList = new List<string>();
        
        Map<id,List<cgcloud__Order_Item__c>> orderIdToItemsMap = new Map<id,List<cgcloud__Order_Item__c>> ();
        Map<string, cgcloud__Inventory__c> accountAndProductToInventoryMap = new  Map<string, cgcloud__Inventory__c>();
        
        cgcloud__Order_Template__c salesTemplate = [SELECT Id 
                                                    FROM cgcloud__Order_Template__c 
                                                    WHERE Name ='Retailer Order Template' 
                                                    AND cgcloud__Active__c = true
                                                    LIMIT 1];
        
        
        // Check for orders with the "Approved" status and Approval_Status__c equal to "Approved"
        for (cgcloud__Order__c updatedOrder : newList) {
            if ( oldMap.get(updatedOrder.Id).Orel_Order_status__c != updatedOrder.Orel_Order_status__c
                && updatedOrder.Orel_Order_status__c == 'Invoice generated' 
                && updatedOrder.cgcloud__Order_Template__c == salesTemplate.Id) 
            {
                
                salesOrgsList.add(updatedOrder.cgcloud__Order_Template__c);
                approvedOrderIds.add(updatedOrder.Id);
                distributorIdsApproved.add(updatedOrder.cgcloud__Order_Account__c);
                newListApproved.add(updatedOrder);
            }
        }
        
        
        //List of All order line item       
        For(cgcloud__Order_Item__c item : [SELECT Id, Name, cgcloud__Quantity__c, cgcloud__Product__c, cgcloud__Product__r.Name, cgcloud__Order__r.cgcloud__Order_Account__c, cgcloud__Order__r.cgcloud__Order_Account__r.Name, cgcloud__Order__r.cgcloud__Order_Template__r.Name, cgcloud__Order__r.cgcloud__Visit__r.AccountId
                                           FROM cgcloud__Order_Item__c
                                           WHERE cgcloud__Order__c IN :approvedOrderIds]){
                                               
                                               //Collecting Product Ids to fetch inventories
                                               ProductIds.add(item.cgcloud__Product__c);
                                               
                                               If(orderIdToItemsMap.containsKey(item.cgcloud__Order__c)){
                                                   orderIdToItemsMap.get(item.cgcloud__Order__c).add(item);
                                               }Else{
                                                   orderIdToItemsMap.put(item.cgcloud__Order__c,new List<cgcloud__Order_Item__c>{item});
                                               }
                                               
                                           }
        
        List<string> inventoryTypes = new List<string>{'Van Inventory'};
            
            //Get the account and product map to inventory
            accountAndProductToInventoryMap = GetInventoryMap(ProductIds, distributorIdsApproved, 'Primary Inventory', inventoryTypes);
        If(orderIdToItemsMap.keyset().size()>0){
            //Create inventory transactions
            CreateInventoryTransactions(accountAndProductToInventoryMap, newListApproved, orderIdToItemsMap);
        }
        
        
    }
    
    
    /*******************************************************************************************************************************************************************/    
    //Method to get the map of account+product to Inventory
    
    Public static Map<string, cgcloud__Inventory__c> GetInventoryMap(Set<Id> ProductIds, Set<Id> distributorIds, string InventoryTemplateType, List<string> inventoryTypes){
        
        system.debug('inside inventory>>');
        
        Map<string, cgcloud__Inventory__c> accountAndProductToInventoryMap = new Map<string, cgcloud__Inventory__c>();
        RecordType rctype = [SELECT Id FROM RecordType WHERE sObjectType = 'cgcloud__Inventory_Control_Template__c' AND DeveloperName = 'Inventory' LIMIT 1];
        system.debug('recordtype>>'+ rctype);
        system.debug('ProductIds>>'+ ProductIds);
        system.debug('distributorIds>>'+ distributorIds);
        
        //Fetch the Company Account 
        List<Account> CompanyAccounts = [SELECT Id from Account WHERE Type__c = 'Company' LIMIT 1];
        IF(CompanyAccounts.size() > 0){
            distributorIds.add(CompanyAccounts[0].Id);
        }
        
        // Query the Inventory record based on the product Id and additional Id
        List<cgcloud__Inventory__c> inventoryList = [SELECT Id, cgcloud__Account__c, cgcloud__Account__r.Name, cgcloud__Product__c, cgcloud__Product__r.Name,Inventory_Control_Template_Type__c,Orl_Inventory_type__c, cgcloud__Balance__c, Name
                                                     FROM cgcloud__Inventory__c
                                                     WHERE cgcloud__Product__c IN :ProductIds
                                                     AND cgcloud__Account__c IN :distributorIds 
                                                     AND Orl_Inventory_type__c IN :inventoryTypes
                                                     AND Inventory_Control_Template_Type__c = :InventoryTemplateType
                                                     AND cgcloud__Inventory_Template__r.RecordTypeId = :rctype.Id
                                                     //AND cgcloud__Valid_Thru__c >= TODAY
                                                     //AND cgcloud__Valid_From__c <= TODAY
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
    
    Public static void CreateInventoryTransactions(Map<string, cgcloud__Inventory__c> accountAndProductToInventoryMap, List<cgcloud__Order__c> newList1, Map<id,List<cgcloud__Order_Item__c>> orderIdToItemsMap){
        
        
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
        
        
        for (cgcloud__Order__c updatedOrder : newList1) {
            
            If(orderIdToItemsMap.get(updatedOrder.Id) != null){
                
                
                For(cgcloud__Order_Item__c item : orderIdToItemsMap.get(updatedOrder.Id)){
                    
                    
                    //For PO-SO orders START
                    If(item.cgcloud__Order__r.cgcloud__Order_Template__r.Name == 'Sales Template'){
                        
                        If(updatedOrder.GRNGenerated__c == 'Completed'){
                            
                            //Check the inventory
                            If(accountAndProductToInventoryMap.get((string)CompanyAccount.Id+(string)item.cgcloud__Product__c+'Hold Inventory') != null 
                               && accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Distributor Inventory') != Null){
                                   
                                   
                                   cgcloud__Inventory_Transaction__c inventoryTransaction = GenerateInventoryTransaction(item, 
                                                                                                                         typeTotemplateIdMap.get('Withdraw'), 
                                                                                                                         accountAndProductToInventoryMap.get((string)CompanyAccount.Id+(string)item.cgcloud__Product__c+'Hold Inventory'), 
                                                                                                                         'substract', 'Sales Order by distributor', updatedOrder);
                                   cgcloud__Inventory_Transaction__c inventoryTransaction1 = GenerateInventoryTransaction(item, 
                                                                                                                          typeTotemplateIdMap.get('Add'), 
                                                                                                                          accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Distributor Inventory'), 
                                                                                                                          'add', 'Sales Order by distributor', updatedOrder);   
                                   
                                   
                                   
                                   inventoryListToUpdate.addAll(new List<cgcloud__Inventory_Transaction__c>{inventoryTransaction,inventoryTransaction1});
                                   system.debug('testing 1'+inventoryListToUpdate);
                               }
                            
                            //Inventory is not present
                            else If(accountAndProductToInventoryMap.get((string)CompanyAccount.Id+(string)item.cgcloud__Product__c+'Hold Inventory') == null){
                                updatedOrder.GRNGenerated__c.addError('Please add Primary Hold Inventory for '+item.cgcloud__Product__r.Name);
                            }else If(accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Distributor Inventory') == null){
                                updatedOrder.GRNGenerated__c.addError('Please add Distributor Primary Inventory for '+item.cgcloud__Product__r.Name);
                            }
                            
                        }
                    }
                    //For PO-SO orders END
                    
                    
                    //For retailer orders START
                    Else If(item.cgcloud__Order__r.cgcloud__Order_Template__r.Name == 'Retailer Order Template'){
                        If(updatedOrder.Orel_Order_status__c == 'Invoice generated'){
                            //Check the inventory
                            If(accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Van Inventory') != Null){
                                
                                cgcloud__Inventory_Transaction__c inventoryTransaction1 = GenerateInventoryTransaction(item, 
                                                                                                                       typeTotemplateIdMap.get('Withdraw'), 
                                                                                                                       accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Van Inventory'), 
                                                                                                                       'substract', 'Order from Retailer', updatedOrder);
                                
                                
                                inventoryListToUpdate.addAll(new List<cgcloud__Inventory_Transaction__c>{inventoryTransaction1});
                            }
                            
                            //Inventory is not present
                            
                            else {
                                system.debug('should show th eeroor1');
                                updatedOrder.Orel_Order_status__c.addError('Please add Distributor Van Inventory for the product '+item.cgcloud__Product__r.Name);
                            }
                        }
                        
                    }
                    
                    //For retailer orders END
                    
                    
                    //For Return orders START
                    Else If(item.cgcloud__Order__r.cgcloud__Order_Template__r.Name == 'Return'){
                        If(updatedOrder.Orl_Return_Status__c == 'Approved'){
                            
                            system.debug('inside approved');
                            
                            //Check Inventory
                            If(accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Van Inventory') != null){
                                cgcloud__Inventory_Transaction__c inventoryTransaction = GenerateInventoryTransaction(item, 
                                                                                                                      typeTotemplateIdMap.get('Add'), 
                                                                                                                      accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Van Inventory'), 
                                                                                                                      'add', 
                                                                                                                      'Return order from retailer', updatedOrder);
                                
                                inventoryListToUpdate.add(inventoryTransaction);
                                
                            }Else{
                                updatedOrder.Orl_Return_Status__c.addError('Please add Distributor Van Inventory');
                            }
                            
                        }Else If(updatedOrder.Orl_Return_Status__c == 'Received at distributor W/H'){
                            system.debug('inside Received at distributor W/H');
                            
                            //Check the inventory
                            If(accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Van Inventory') != null 
                               && accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Distributor Inventory') != Null){
                                   
                                   cgcloud__Inventory_Transaction__c inventoryTransaction = GenerateInventoryTransaction(item, 
                                                                                                                         typeTotemplateIdMap.get('Withdraw'), 
                                                                                                                         accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Van Inventory'), 
                                                                                                                         'substract', 'Return order from retailer', updatedOrder);
                                   cgcloud__Inventory_Transaction__c inventoryTransaction1 = GenerateInventoryTransaction(item, 
                                                                                                                          typeTotemplateIdMap.get('Add'), 
                                                                                                                          accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Distributor Inventory'), 
                                                                                                                          'add', 'Return order from retailer', updatedOrder);          
                                   
                                   inventoryListToUpdate.addAll(new List<cgcloud__Inventory_Transaction__c>{inventoryTransaction,inventoryTransaction1});
                               }
                            
                            //Inventory is not present
                            else If(accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Van Inventory') == null){
                                system.debug('accountAndProductToInventoryMap>>'+accountAndProductToInventoryMap);
                                updatedOrder.Orl_Return_Status__c.addError('Please add Distributor Van Inventory(Return) for '+item.cgcloud__Product__r.Name);
                            }else If(accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Distributor Inventory') == null){
                                updatedOrder.Orl_Return_Status__c.addError('Please add Distributor Inventory(Return) for'+item.cgcloud__Product__r.Name);
                            }
                            
                            
                        }Else If(updatedOrder.Orl_Return_Status__c == 'Sent to Orel W/H'){
                            system.debug('inside Sent to Orel W/H');
                            
                            //Check the inventory
                            If(accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Van Inventory') != null 
                               && accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Distributor Inventory') != Null){                           
                                   
                                   cgcloud__Inventory_Transaction__c inventoryTransaction = GenerateInventoryTransaction(item, 
                                                                                                                         typeTotemplateIdMap.get('Add'), 
                                                                                                                         accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Van Inventory'), 
                                                                                                                         'add', 'Return order from distributor', updatedOrder);
                                   cgcloud__Inventory_Transaction__c inventoryTransaction1 = GenerateInventoryTransaction(item, 
                                                                                                                          typeTotemplateIdMap.get('Withdraw'), 
                                                                                                                          accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Distributor Inventory'), 
                                                                                                                          'substract', 'Return order from distributor', updatedOrder);
                                   
                                   inventoryListToUpdate.addAll(new List<cgcloud__Inventory_Transaction__c>{inventoryTransaction,inventoryTransaction1});
                               }
                            
                            //Errors if Inventory is not present
                            else If(accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Van Inventory') == null){
                                updatedOrder.Orl_Return_Status__c.addError('Please add Distributor Van Inventory(Return) for '+item.cgcloud__Product__r.Name);
                            }else If(accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Distributor Inventory') == null){
                                updatedOrder.Orl_Return_Status__c.addError('Please add Distributor Inventory(Return) for '+item.cgcloud__Product__r.Name);
                            }
                            
                        }Else If(updatedOrder.Orl_Return_Status__c == 'Received at Orel W/H'){
                            system.debug('inside Received at Orel W/H');
                            
                            //Check the inventory
                            If(accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Van Inventory')!= null 
                               && accountAndProductToInventoryMap.get((string)CompanyAccount.Id+(string)item.cgcloud__Product__c+'Company Inventory')!= Null){    
                                   
                                   cgcloud__Inventory_Transaction__c inventoryTransaction = GenerateInventoryTransaction(item, 
                                                                                                                         typeTotemplateIdMap.get('Withdraw'), 
                                                                                                                         accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Van Inventory'), 
                                                                                                                         'substract', 
                                                                                                                         'Return order from distributor', updatedOrder);
                                   cgcloud__Inventory_Transaction__c inventoryTransaction1 = GenerateInventoryTransaction(item, 
                                                                                                                          typeTotemplateIdMap.get('Add'), 
                                                                                                                          accountAndProductToInventoryMap.get((string)CompanyAccount.Id+(string)item.cgcloud__Product__c+'Company Inventory'), 
                                                                                                                          'add', 
                                                                                                                          null, updatedOrder);
                                   
                                   inventoryListToUpdate.addAll(new List<cgcloud__Inventory_Transaction__c>{inventoryTransaction,inventoryTransaction1});
                               }
                            //Inventory is not present
                            else If(accountAndProductToInventoryMap.get((string)item.cgcloud__Order__r.cgcloud__Order_Account__c+(string)item.cgcloud__Product__c+'Van Inventory') == null){
                                updatedOrder.Orl_Return_Status__c.addError('Please add Distributor Van Inventory (Return) for '+item.cgcloud__Product__r.Name);
                            }else If(accountAndProductToInventoryMap.get((string)CompanyAccount.Id+(string)item.cgcloud__Product__c+'Company Inventory') == Null){
                                updatedOrder.Orl_Return_Status__c.addError('Please add Distributor Inventory (Return) for '+item.cgcloud__Product__r.Name);
                            }
                            
                        }
                        //For Return orders END 
                    }
                }
            }
        }
        
        For(cgcloud__Inventory_Transaction__c inv: inventoryListToUpdate)
            system.debug('inventoryListToUpdate>>'+inv);
        
        Insert inventoryListToUpdate;
        
    }
    
    /**********************************************************************************************************************************************************************************/
    //method to create inventory
    
    Public static cgcloud__Inventory_Transaction__c GenerateInventoryTransaction(cgcloud__Order_Item__c item, string templateId, cgcloud__Inventory__c inventory, string actionType, string transactionStatus, cgcloud__Order__c updatedOrder){
        
        system.debug('product>>'+item);
        
        cgcloud__Inventory_Transaction__c inventoryTransaction = new cgcloud__Inventory_Transaction__c();
        
        inventoryTransaction.cgcloud__Inventory__c = inventory.Id;
        
        If(actionType == 'substract'){
            
            If(item.cgcloud__Quantity__c > inventory.cgcloud__Balance__c){
                updatedOrder.addError('Insufficient balance in the inventory '+inventory.Name+' for product '+item.cgcloud__Product__r.Name);
            }
            
            inventoryTransaction.cgcloud__Amount__c = -item.cgcloud__Quantity__c;
        }else{
            inventoryTransaction.cgcloud__Amount__c = item.cgcloud__Quantity__c;
        }
        
        inventoryTransaction.cgcloud__Order_Item__c = item.Id;
        inventoryTransaction.cgcloud__Order_Document__c = item.cgcloud__Order__c;
        inventoryTransaction.cgcloud__Inventory_Transaction_Template__c = templateId;
        If(transactionStatus != null && transactionStatus != '')
            inventoryTransaction.Orl_Order_transaction_status__c = transactionStatus;        
        Return inventoryTransaction;
        
    }
    
    public class InsufficientBalanceException extends Exception {}
    
    @future(callout = true)
    Public static void sendInvoice(List<string> orderIds){
        system.debug('sending the invoice');
        
        List<Orl_invoice__c> InvoiceList = [SELECT Id, Advanced_Order__r.cgcloud__Responsible__c FROM Orl_invoice__c];
        List<ContentVersion> versionToInsert = new List<ContentVersion>();
        List<ContentVersion> successVersions = new List<ContentVersion>();
        List<ContentVersion> failedVersions = new List<ContentVersion>();
        List<Database.SaveResult> saveResults;
        Map<Id, ContentDocument> contentDocumentMap = new Map<Id, ContentDocument>();
        Set<Id> succeededIds = new set<id>();
        
        For(Orl_invoice__c invoice:InvoiceList){
            
            PageReference pdfPage1 = Page.InvoicePdfGenerator; 
            pdfPage1.getParameters().put('id', invoice.Id);
            Blob pdfBlob1;
            if (!Test.isRunningTest()) {
                pdfBlob1= pdfPage1.getContent();
            } else { 
                pdfBlob1 = Blob.valueOf('Test');
            }
            /*
            // Create Attachment record
            Attachment att1 = new Attachment();
            att1.Name = 'RTO & Insurance Receipt-pdf';
            att1.Body = pdfBlob1;
            att1.ParentId = 'order.Id';
            att1.ContentType = 'application/pdf';
            */
            
            ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.VersionData = Blob.valueOf('string');
            ContVerFile.Title = 'title'; 
            ContVerFile.ContentLocation= 's';
            ContVerFile.PathOnClient='title.csv';
            versionToInsert.add(ContVerFile);
      //insert ContVerFile;

        }
        
       
        
        try {
            if (!versionToInsert.isEmpty()) {
                saveResults = database.Insert(versionToInsert, false);
                
                // Check results for successful versions
                for (Integer i = 0; i < saveResults.size(); i++) {
                    if (saveResults[i].isSuccess()) {
                        system.debug('Successfully inserted version with ID: ' + saveResults[i].getId());
                        successVersions.add(versionToInsert[i]);
                        succeededIds.add(versionToInsert[i].Id);
                        
                    } else {
                        system.debug('Failed to insert version with error: ' + saveResults[i].getErrors()[0].getMessage());
                        failedVersions.add(versionToInsert[i]);
                    }
                }
            }
        } catch(Exception e) {
            system.debug('Failed to insert successful versions: ' + e);
        }
        
        
        If(succeededIds.size()>0)
        For(ContentVersion cversion : successVersions){
            
        }

        
        
        
        
//attachmentsToInsert.add(att1); 
    }
    
    
    
}