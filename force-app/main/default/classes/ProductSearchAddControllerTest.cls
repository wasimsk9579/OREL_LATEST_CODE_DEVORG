@isTest
private class ProductSearchAddControllerTest 
{
    static testMethod void validateGetProducts()
    {
        Product2 prod = new Product2();
        prod.Name = 'Connector';
        prod.cgcloud__Consumer_Goods_Product_Code__c = 'abc123';
        prod.CurrencyIsoCode = 'LKR';
        prod.IsActive = true;
        prod.Description = 'Connector is used in highly level machine design';
        insert prod;
        Test.startTest();
        List<Product2> prodList = ProductSearchAddController.getProducts();
        //System.assertEquals(0, products.size());
        Test.stopTest();
    }
}