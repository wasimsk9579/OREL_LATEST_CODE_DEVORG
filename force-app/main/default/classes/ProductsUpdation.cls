public class ProductsUpdation 
{
    public static void updateProducts()
    {
        List<Product2> initProdList = new List<Product2>([Select Id, cgcloud__Order_Ability__c, cgcloud__State__c, cgcloud__Competitive_Product__c, (Select Id from cgcloud__Units_of_Measure__r) from Product2 where Id NOT IN (Select cgcloud__Product__c from cgcloud__Unit_of_Measure__c)]);
        Map<Id,Product2> initProdMap = new Map<Id,Product2>(initProdList);
        List<Product2> updateList = new List<Product2>();
        List<cgcloud__Unit_of_Measure__c> uomList = new List<cgcloud__Unit_of_Measure__c>();
        System.debug('ProdList::'+initProdList);
        for(Product2 prod : initProdList) 
        {
            prod.cgcloud__Field_Valid_From__c = Date.newInstance(2023, 7, 26);
            prod.cgcloud__Delivery_Valid_From__c = Date.newInstance(2023, 7, 26);
            prod.cgcloud__Field_Valid_Thru__c = Date.newInstance(2111, 12, 26);
            prod.cgcloud__Delivery_Valid_Thru__c = Date.newInstance(2111, 12, 26);
            prod.cgcloud__Order_Ability__c = 1000;
            prod.cgcloud__State__c = '4';
            prod.cgcloud__Competitive_Product__c = false;
            //prod.cgcloud__Category__c = 'Non-Wired Panel';
            updateList.add(prod);
            if(!(initProdMap.get(prod.Id).cgcloud__Units_of_Measure__r.size()>0))
            {
                System.debug('ProductId::'+prod.Id);
                cgcloud__Unit_of_Measure__c uom = new cgcloud__Unit_of_Measure__c();
                uom.cgcloud__Product__c = prod.Id;
                uom.cgcloud__Is_Order_Unit__c = true;
                uom.cgcloud__Order_Ability__c = true;
                uom.cgcloud__Is_Price_Unit__c = true;
                uom.cgcloud__Unit_Type__c = 'SalesUnit';
                uom.cgcloud__Sort__c = 1;
                uomList.add(uom);
            }
        }
        if(updateList!=null && updateList.size()>0)
            update updateList;
        if(uomList!=null && uomList.size()>0)
        {
            Database.SaveResult[] uomInsert = Database.insert(uomList, false);
            for (Database.SaveResult sr : uomInsert) {
            if (sr.isSuccess()) {
                System.debug('success::');
                System.debug('UOM Id::'+sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('fields that affected this error: ' + err.getFields());
                }
            }
		}
        }
    }  
}