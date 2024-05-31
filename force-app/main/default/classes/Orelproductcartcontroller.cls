public with sharing class Orelproductcartcontroller {
    @AuraEnabled(cacheable=true)
    public static List<Product2> getproduct() {
        List<Product2> prolist = [SELECT Id, Name, Image__c FROM Product2 WHERE Id IN ('01tH4000000PksGIAS', '01tH4000000PuE6IAK')];

       
         system.debug('product record' +prolist);

        	
         return prolist;
    

    }
}