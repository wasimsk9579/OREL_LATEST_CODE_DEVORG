public with sharing class Orelcarttablecontroller {
    @AuraEnabled
    public static List<Product2> getcartproduct(list<string> productId,String currentUserId) {
        system.debug('currentUserId'+currentUserId);
        String priceBookId = [SELECT Id, Name, Account.Price_Book__c 
                                            FROM User
                                            WHERE Id =: currentUserId].Account.Price_Book__c;
      
            system.debug('pricebookId' +priceBookId);
        system.debug('Id'+productId.size());
        List<Product2> cartprolist = [Select Id, Name, ProductCode, Image__c,
            (SELECT Id, Pricebook2Id, UnitPrice, Product2Id FROM PricebookEntries 
             where Pricebook2Id=:priceBookId)
            FROM Product2 Where ID=:productId];
        system.debug('inventory record' +cartprolist);
        return cartprolist;
    }
}
