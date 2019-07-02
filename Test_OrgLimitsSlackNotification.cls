@isTest
private class Test_OrgLimitsSlackNotification {
    /**
    @description: Call asynchronous callout and check if synchronous callout response is equal to expected value from HttpCalloutMock 
    */
	@isTest static void verifyOrgLimitsNotificationPostsSlackMessageSuccesfully() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new OrgLimitsSlackNotificationCalloutMock());
              
        Test.startTest();
            // Call method to test.
            OrgLimitsSlackNotification.checkLimitsAndSendWebhook(90);
        Test.stopTest();
        
        // This causes a fake response to be sent from the class that implements HttpCalloutMock
        HttpResponse response = OrgLimitsSlackNotification.SlackPostCallout('test');
        // Verify response received fake values
        final String SLACK_NOTIFICATION_NOT_SENT = 'HTTP request not succeeded';
        System.assertEquals(200, response.getStatusCode(), SLACK_NOTIFICATION_NOT_SENT);
    } 
}