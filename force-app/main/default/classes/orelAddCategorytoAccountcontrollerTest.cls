@isTest
private class orelAddCategorytoAccountcontrollerTest {

    @isTest
    static void testGetCategoryProducts() {
        ProductCatalog testcat = new ProductCatalog(
        Name='test catalog');
        insert testcat;
        // Test data setup
        List<ProductCategory> testCategories = new List<ProductCategory>{
            new ProductCategory(Name = 'Category 1',CatalogId=testcat.Id),
            new ProductCategory(Name = 'Category 2',CatalogId=testcat.Id)
                
        };
        insert testCategories;

        Test.startTest();
        // Test the getCategoryProducts method
        List<ProductCategory> resultCategories = orelAddCategorytoAccountcontroller.getCategoryProducts();
        Test.stopTest();

        // Verify results
        System.assertEquals(2, resultCategories.size(), 'Unexpected number of categories returned');
    }

    @isTest
    static void testUpdateAccountCategoryField() {
        // Test data setup
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Test.startTest();
        // Test the updateAccountCategoryField method
        orelAddCategorytoAccountcontroller.updateAccountCategoryField(testAccount.Id, 'Test Categories');
        Test.stopTest();

        // Verify results
        Account updatedAccount = [SELECT Categories__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals('Test Categories', updatedAccount.Categories__c, 'Categories not updated successfully');
    }

    @isTest
    static void testGetAccountCustomCategoryField() {
        // Test data setup
        Account testAccount = new Account(Name = 'Test Account', Categories__c = 'Test Categories');
        insert testAccount;

        Test.startTest();
        // Test the getAccountCustomCategoryField method
        String result = orelAddCategorytoAccountcontroller.getAccountCustomCategoryField(testAccount.Id);
        Test.stopTest();

        // Verify results
        System.assertEquals('Test Categories', result, 'Incorrect categories retrieved');
    }
}