@isTest
private class OrlReturnOrderControllerTest {

    @isTest
    static void testGetReturnOrder() {
        // Create a test User
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser56@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert testUser;
        
          string useraccId =[SELECT Id,AccountId FROM User Limit 1 ].AccountId;
cgcloud__Order_Template__c ret = new cgcloud__Order_Template__c();
        insert ret;
        // Create a test Order for the User
        cgcloud__Order__c testOrder = new cgcloud__Order__c(
            cgcloud__Order_Account__c = useraccId,
            cgcloud__Order_Template__c = ret.Id
        );
        insert testOrder;

        Test.startTest();
        List<cgcloud__Order__c> returnOrders = OrlReturnOrderController.getReturnorder(testUser.Id);
        Test.stopTest();

    }

    @isTest
    static void testUpdateOrderStatus() {
        cgcloud__Order_Template__c ret = new cgcloud__Order_Template__c();
        insert ret;
        // Create a test Order
        cgcloud__Order__c testOrder = new cgcloud__Order__c(
            Orl_Return_Status__c = 'Pending',
             cgcloud__Order_Template__c = ret.Id
        );
        insert testOrder;

        Test.startTest();
        OrlReturnOrderController.updateOrderStatus(testOrder.Id, 'Completed');
        Test.stopTest();

        // Retrieve the updated Order
        cgcloud__Order__c updatedOrder = [SELECT Id, Orl_Return_Status__c FROM cgcloud__Order__c WHERE Id = :testOrder.Id];
        
       
    }

    @isTest
    static void testGetSalesOrder() {
        // Create a test User
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser57@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert testUser;

        cgcloud__Order_Template__c ret = new cgcloud__Order_Template__c();
        insert ret;
        // Create a test Order for the User
        cgcloud__Order__c testOrder = new cgcloud__Order__c(
            cgcloud__Order_Account__c = testUser.Id,
            cgcloud__Order_Template__c = ret.Id
        );
        insert testOrder;

        Test.startTest();
        List<cgcloud__Order__c> salesOrders = OrlReturnOrderController.getsalesorder(testUser.Id);
        Test.stopTest();

        // Assert results
        System.assertEquals(1, salesOrders.size());
        System.assertEquals(testOrder.Id, salesOrders[0].Id);
    }

    @isTest
    static void testUpdateSalesOrder() {
        cgcloud__Order_Template__c ret = new cgcloud__Order_Template__c();
        insert ret;
        // Create a test Order
        cgcloud__Order__c testOrder = new cgcloud__Order__c(
            GRNGenerated__c = 'Completed',
            cgcloud__Order_Template__c = ret.Id
        );
        insert testOrder;

        Test.startTest();
        OrlReturnOrderController.updatesalesorder(testOrder.Id);
        Test.stopTest();

        // Retrieve the updated Order
        cgcloud__Order__c updatedOrder = [SELECT Id, GRNGenerated__c FROM cgcloud__Order__c WHERE Id = :testOrder.Id];
        
        // Assert the GRNGenerated field is updated
        System.assertEquals('Completed', updatedOrder.GRNGenerated__c);
    }

    @isTest
    static void testGetReturnToOrel() {
        // Create a test User
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser58@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert testUser;

        // Create a test Order for the User
        cgcloud__Order__c testOrder = new cgcloud__Order__c(
            cgcloud__Order_Account__c = testUser.Id,
            cgcloud__Order_Template__c = 'Return',
            Bundle__c = true
        );
        insert testOrder;

        Test.startTest();
        List<cgcloud__Order__c> returnToOrelOrders = OrlReturnOrderController.getReturntoorel(testUser.Id);
        Test.stopTest();

        // Assert results
        System.assertEquals(1, returnToOrelOrders.size());
        System.assertEquals(testOrder.Id, returnToOrelOrders[0].Id);
    }

    @isTest
    static void testGetRetailOrder() {
        // Create a test User
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser59@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert testUser;
        
         string useraccId =[SELECT Id,AccountId FROM User Limit 1 ].AccountId;

         cgcloud__Order_Template__c ret = new cgcloud__Order_Template__c();
        insert ret;
        // Create a test Order for the User
        cgcloud__Order__c testOrder = new cgcloud__Order__c(
            cgcloud__Order_Account__c = useraccId,
            cgcloud__Order_Template__c = ret.Id
        );
        insert testOrder;

        Test.startTest();
        List<cgcloud__Order__c> retailOrders = OrlReturnOrderController.getretailorder(testUser.Id);
        Test.stopTest();


    }
}