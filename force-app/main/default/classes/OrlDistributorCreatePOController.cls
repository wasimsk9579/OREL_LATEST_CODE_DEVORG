public without sharing class OrlDistributorCreatePOController {

  @AuraEnabled
    public static List<ProductCategory> getcartCategoryProducts() {
        List<ProductCategory> cartprolist = [SELECT Id, Name,Category_Image__c,Category_code__c FROM ProductCategory];
        system.debug('category' +cartprolist);
        return cartprolist;
    }

       @AuraEnabled
    public static List<ProductCategoryProduct> getCategoryProducts(string catid) {
        List<ProductCategoryProduct> cartlist = [SELECT Id, ProductCategoryId,ProductId FROM ProductCategoryProduct where ProductCategoryId=:catid];
        system.debug('ProductCategoryProduct' +cartlist);
        return cartlist;
    }


    @AuraEnabled
    public static List<Product2> getProductsForDistributor(string catid,String currentUserId){
        try {
            System.debug('cartproid -- ' + catid);
            System.debug('currentUserId -- ' + currentUserId);
            String priceBookId =  OrlDistributorCreatePOController.getUserPriceBookId(currentUserId);
            system.debug('pricebookId' +priceBookId);
            List<String> categoryList =  OrlDistributorCreatePOController.getProductCategories(currentUserId);
            System.debug('categoryList -- ' + categoryList);

            // List<Product2> productList = [Select Id, Name, ProductCode, Image__c,
            //                                 (SELECT Id, Pricebook2Id, UnitPrice 
            //                                 FROM PricebookEntries 
            //                                 WHERE Pricebook2Id =: priceBookId), 
            //                                 (SELECT Id, Name, ProductCategory.Name 
            //                                 FROM ProductCategoryProducts
            //                                 WHERE ProductCategory.Name =: categoryList) 
            //                                 FROM Product2 
            //                                 WHERE Id 
            //                                 IN (
            //                                     SELECT productId 
            //                                     FROM ProductCategoryProduct 
            //                                     WHERE ProductCategory.Name =: categoryList
            //                                     AND ProductCategory.Name != null 
            //                                     AND ProductCategory.Name != ''
            //                                     ) 
            //                             ];

       
            List<Product2> productList = [Select Id, Name, ProductCode, Image__c,
            (SELECT Id, Pricebook2Id, UnitPrice 
            FROM PricebookEntries 
            WHERE Pricebook2Id =: priceBookId), 
            (SELECT Id, Name, ProductCategory.Name,ProductCategoryId
            FROM ProductCategoryProducts
            WHERE ProductCategoryId=: catid) 
            FROM Product2 
            WHERE Id 
            IN (
                SELECT productId 
                FROM ProductCategoryProduct 
                WHERE ProductCategoryId =: catid
                AND ProductCategory.Name != null 
                AND ProductCategory.Name != ''
                ) 
        ];



            System.debug('productList -- ' + productList);

        
           
            return productList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static string createPurchaseOrder(String userId, String poLineItemsData){
        try {
            System.debug('Data - ' + poLineItemsData);
            System.debug('UserId - ' + userId);
            User us = [SELECT Id, FirstName, LastName, AccountId, Account.Name, ContactId FROM User WHERE Id =: userId LIMIT 1];
            RecordType recordId = [SELECT Id, Name FROM RecordType where Name = 'Purchase'];
            Pricebook2 pbid = [SELECT Id, Name FROM Pricebook2 where Name= 'Standard Price Book'];
            // Create Opportunity for account
            Opportunity opp = new Opportunity();
            opp.Name = us.Account.Name + ' ';
            opp.AccountId = us.AccountId;
            opp.CloseDate = System.today();
            opp.StageName = 'Qualification';
            opp.RecordTypeId = recordId.Id;
            opp.PO_Type__c='ARS/Disti Placed';

            insert opp;
            System.debug('poLineItemsData::'+poLineItemsData);
            List<object> productList = (List<object>) JSON.deserializeUntyped(poLineItemsData);
            Map<Id,object> prIdObjMap = new Map<Id,object>();
            Set<Id> prodIdSet = new Set<Id>();

            for(object pr: productList){
                System.debug('pr - ' + pr);
                Map<String,object> prMap = (Map<String,object>)pr;
                prIdObjMap.put(String.valueOf(prMap.get('Id')), prMap);
                prodIdSet.add(String.valueOf(prMap.get('Id')));
            }
            
            // Set<Id> prodIdSet = prIdObjMap.keySet();
            System.debug('prodIdSet -' + prodIdSet);
            List<PricebookEntry> prodPriceList = [SELECT Id, Name, Pricebook2Id, Product2Id, UnitPrice
                                                    FROM PricebookEntry 
                                                    WHERE Product2Id =: prodIdSet
                                                    AND Pricebook2Id =:pbid.Id];

             System.debug('prodPriceList - '+ prodPriceList);
            List<OpportunityLineItem> oppLineItems = new  List<OpportunityLineItem>();
            for(PricebookEntry pre: prodPriceList){
                System.debug(prIdObjMap.get(pre.Id));
                Map<String,object> singleProductMap = (Map<String,object>)prIdObjMap.get(pre.Id);

                OpportunityLineItem lineItem = new OpportunityLineItem();
                lineItem.Product2Id = pre.Product2Id;
                lineItem.Quantity = Integer.valueOf(singleProductMap.get('AskedQuantity'));
                lineItem.OpportunityId = opp.Id;
                lineItem.PricebookEntryId = pre.Id;
                lineItem.UnitPrice = pre.UnitPrice;

                oppLineItems.add(lineItem);
            }
            if(oppLineItems.size() > 0){
                insert oppLineItems;
            }

        } catch (Exception e) {
            System.debug('exception '+e);
            throw new AuraHandledException(e.getMessage());
        }
        return 'Success';
    }

    public static String getUserPriceBookId(String userId) {
        try {
            String userAccountPriceBook = [SELECT 
                                            Id, Name, Account.Price_Book__c 
                                            FROM User
                                            WHERE Id =: userId].Account.Price_Book__c;

           System.debug('userAccountPriceBook -- ' + userAccountPriceBook);
           return userAccountPriceBook;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List<String> getProductCategories(String userId) {
        try {
            String categoryString = [SELECT Id, Name, Account.Categories__c 
                                    FROM User
                                    WHERE Id =: userId].Account.Categories__c;

            List<String> categoryList = categoryString.split(',');
        return categoryList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // @AuraEnabled
    // public static string createOppAndOppLineItems(String userId,  String poLineItemsData, list<integer> askQuantity,List<Map<String, Object>> listOfObjects){
    // try {
    //     System.debug('askQuantity: ' + askQuantity);
    //     System.debug('poLineItemsData: ' + listOfObjects);

    //     // If all checks pass, proceed to create Opportunity and Line Items

    //     // List<OrlDistributorCreatePOWrapper> lineItemWrappers = (List<OrlDistributorCreatePOWrapper>)JSON.deserialize(poLineItemsData, List<OrlDistributorCreatePOWrapper>.class);
    //     // system.debug('lineItemWrappers'+lineItemWrappers);
    
    



    //     String OppRecordTypeId = [SELECT Id, Name 
    //                                 FROM RecordType 
    //                                 WHERE SObjectType = 'Opportunity' 
    //                                 AND Name = 'Purchase'
    //                              ].Id;

    //     User us = [SELECT Id, FirstName, LastName, AccountId, Account.Name, Account.Price_Book__c, ContactId
    //                         FROM User 
    //                         WHERE Id = :userId 
    //                         AND AccountId != null
    //                         LIMIT 1
    //                     ];

    //     Set<String> productIdSet = new Set<String>();
    //     for(Map<String, Object> obj : listOfObjects){
    //         String productId = (String)obj.get('Product2Id');
    //         system.debug('productId ----> '+productId);
    //         productIdSet.add(productId);
    //         system.debug('productIdSet --->'+productIdSet);
    //     }

    //     Map<String, PricebookEntry> productPriceBookEntryMap = new Map<String, PricebookEntry>();
    //     for(PricebookEntry prEntry : [SELECT Id, Pricebook2Id, Product2Id, UnitPrice 
    //                                     FROM PricebookEntry 
    //                                     WHERE Product2Id IN :productIdSet 
    //                                     AND Pricebook2Id = :us.Account.Price_Book__c]){

    //         productPriceBookEntryMap.put(prEntry.Product2Id, prEntry);
    //     }

    //     Opportunity opp = new Opportunity();
    //     opp.Name = us.Account.Name + ' Purchase';
    //     opp.AccountId = us.AccountId;
    //     opp.CloseDate = System.today();
    //     opp.StageName = 'Qualification';
    //     opp.RecordTypeId = OppRecordTypeId;
    //     insert opp;


    //     map<id,string> productidmap = new map<id,string>();
    //     map<id,String> quantitymap = new  map<id,String>();
    //     map<id,Decimal> pricemap = new  map<id,Decimal>();

    //     List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
    //     for (Map<String, Object> obj : listOfObjects) {
    //         String productId = (String)obj.get('Product2Id');
    //         system.debug('productId ----> '+productId);
    //         String quantity = (String)obj.get('Quantity');
    //         system.debug('quantity ------->'+quantity);
    //         Decimal unitprice = (Decimal)obj.get('UnitPrice');
    //         system.debug('unitprice  ----> '+unitprice);

          
    //         productidmap.put(productId,productId);
    //         quantitymap.put(productId,quantity);
    //         pricemap.put(productId,unitprice);

    //         OpportunityLineItem lineItem = new OpportunityLineItem();
    //         lineItem.Product2Id = productId;
    //         lineItem.Quantity =decimal.valueof(quantity);
    //         lineItem.OpportunityId = opp.Id;
    //         lineItem.PricebookEntryId = productPriceBookEntryMap.get(productId).Id;
    //         system.debug('lineItem.PricebookEntryId --->'+lineItem.PricebookEntryId);
    //         lineItem.UnitPrice = unitprice;

    //         oppLineItems.add(lineItem);
    //     }
    //     insert oppLineItems;

    //     system.debug('oppLineItems'+oppLineItems);

    //     return 'Success'; 

    
    // }  catch (QueryException e) {
    //     String errorMessage = e.getMessage();
    //     throw new AuraHandledException(errorMessage);
    // }




    // }


@AuraEnabled
public static String createOppAndOppLineItems(String userId, String poLineItemsData, List<Integer> askQuantity, List<Map<String, Object>> listOfObjects) {
    try {
        System.debug('askQuantity: ' + askQuantity);
        System.debug('listOfObjects: ' + listOfObjects);

        // Fetch Opportunity Record Type ID for 'Purchase'
        Id oppRecordTypeId = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Opportunity' 
            AND Name = 'Purchase'
            LIMIT 1
        ].Id;

        // Fetch User and Account details
        User us = [
            SELECT Id, AccountId, Account.Name, Account.Price_Book__c 
            FROM User 
            WHERE Id = :userId 
            AND AccountId != null
            LIMIT 1
        ];
 System.debug('us::'+us);
        
        // Collect Product2Id values from listOfObjects
        Set<Id> productIdSet = new Set<Id>();
        for (Map<String, Object> obj : listOfObjects) {
            Id productId = (Id) obj.get('Product2Id');
            productIdSet.add(productId);
        }

        // Fetch PricebookEntries for the Products in the user's Pricebook
        Map<Id, PricebookEntry> productPriceBookEntryMap = new Map<Id, PricebookEntry>();
        System.debug('productIdSet::'+productIdSet);
        for (PricebookEntry prEntry : [
            SELECT Id, Product2Id, UnitPrice 
            FROM PricebookEntry 
            WHERE Product2Id IN :productIdSet 
            AND Pricebook2Id = :us.Account.Price_Book__c]) {
                productPriceBookEntryMap.put(prEntry.Product2Id, prEntry);  
            }

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = us.Account.Name + ' Purchase',
            AccountId = us.AccountId,
            CloseDate = System.today(),
            StageName = 'Qualification',
            RecordTypeId = oppRecordTypeId,
            PO_Type__c='ARS/Disti Placed'
        );
        insert opp;

        // Create Opportunity Line Items
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        for (Map<String, Object> obj : listOfObjects) {
            Id productId = (Id) obj.get('Product2Id');
            System.debug('productId::'+productId);
            Decimal quantity = Decimal.valueOf((String) obj.get('Quantity'));
            Decimal unitPrice = (Decimal) obj.get('UnitPrice');

            OpportunityLineItem lineItem = new OpportunityLineItem();
                lineItem.Product2Id = productId;
                lineItem.Quantity = quantity;
                lineItem.OpportunityId = opp.Id;

            
            System.debug('fcgvh:'+productPriceBookEntryMap);
            if(productPriceBookEntryMap.get(productId).Id!=null){
                lineItem.PricebookEntryId = productPriceBookEntryMap.get(productId).Id;
            }
                
                lineItem.UnitPrice = unitPrice;
            
      system.debug('lineItem::'+lineItem);
            oppLineItems.add(lineItem);
        }

        // Insert all Opportunity Line Items in bulk
        insert oppLineItems;

        System.debug('oppLineItems: ' + oppLineItems);

        return 'Success'; 
    }
    Catch(exception e){
        return e.getMessage();
    }

  /*  } catch (QueryException e) {
        String errorMessage = e.getMessage();
        System.debug('errorMessage::'+e);
        throw new AuraHandledException(errorMessage);
    } catch (DmlException e) { String errorMessage = e.getMessage(); System.debug('errorMessage::'+e);        throw new AuraHandledException(errorMessage);
    } catch (Exception e) {
        String errorMessage = e.getMessage();
        System.debug('errorMessage::'+e);
        throw new AuraHandledException(errorMessage);
    }*/
}


@AuraEnabled(cacheable=true)
public static List<cgcloud__Inventory__c> compoinv(String proId) {
    System.debug('productId: ' + proId);
    
    // Querying for Company Accounts
    List<Account> comaccid = [SELECT Id, Name, Type__c FROM Account WHERE Type__c = 'Company'];
    
    // Creating a set of Account Ids
    Set<Id> accIdSet = new Set<Id>();
    for (Account acc : comaccid) {
        accIdSet.add(acc.Id);
    }     
    System.debug('accIdSet: ' + accIdSet);
    
    // Querying for company inventory related to the provided productId
    List<cgcloud__Inventory__c> listinv = [SELECT Id, Name, cgcloud__Account__c, cgcloud__Product__r.Name, cgcloud__Balance__c, 
    cgcloud__Product__c, Orl_Inventory_type__c, Inventory_Control_Template_Type__c FROM cgcloud__Inventory__c WHERE 
    (Orl_Inventory_type__c = 'Company Inventory' AND Orl_Inventory_type__c != NULL AND
     Inventory_Control_Template_Type__c = 'Primary Inventory' AND cgcloud__Product__c=:proId AND 
     cgcloud__Account__c=:accIdSet)];

    System.debug('company inventory: ' + listinv);
 
    return listinv;
}




// @AuraEnabled(cacheable=true)
// public static List<cgcloud__Inventory__c> compoinv() {
//     return [SELECT Id, Name, cgcloud__Account__c, cgcloud__Product__r.Name, cgcloud__Balance__c, cgcloud__Product__c, Orl_Inventory_type__c, Inventory_Control_Template_Type__c
//             FROM cgcloud__Inventory__c 
//             WHERE Id = 'a39H40000004KIBIA2'];
// }


}