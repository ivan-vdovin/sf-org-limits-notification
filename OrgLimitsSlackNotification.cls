/** 
 * Checks single email org limits and post Slack notifications if needed
 * @author Ivan Vdovin
 * @version 1.0
*/
public class OrgLimitsSlackNotification {

    /** 
     * Message class with a text property to use Slack webhooks format: {"text": "This is a line of text."})
     */
    @testVisible
    private class SlackJson {

        /* Text for a Slack message */
        String text;
        
        /** 
        * Constructor - create a new object with a specific value
        * @param text - Slack message text
        */
        public SlackJson(String text) {
            this.text = text;
        }
    }

    /** 
     * Get current values of single email org limits
     */
    @testVisible
    private class OrgLims {

        /* Value of sent emails */
        Integer singleEmailValue;

        /* Max value */
        Integer singleEmailLimit;

        /** 
        * Constructor - create a new object with a current value of single email org limits
        */
        public OrgLims() {

            /* Workaround for a SF issue with OrgLimits.getMap() call from test context which is used to raise code coverage */ 
            if (Test.isRunningTest()) {
                this.singleEmailValue = 4500;
                this.singleEmailLimit = 5000;
            } else {

                /* Get org limits map */
                Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();

                /* Get single email org limits from the map above */
                System.OrgLimit singleEmailLimit = limitsMap.get('SingleEmail');

                this.singleEmailValue = singleEmailLimit.getValue();
                this.singleEmailLimit = singleEmailLimit.getLimit();
            }
        }
    }

    /**
     * Method for async execution of the slackPostCallout
     */
    @future(callout=true)
    public static void slackPostCalloutAsync(String slackJsonMessage) {
        slackPostCallout(slackJsonMessage);
    }

    /**
     * Method for sending HTTP post callout
     * @param slackJsonMessage - Slack message text
     * @return returns HTTP response
     */
    public static HttpResponse slackPostCallout(String slackJsonMessage) {

        /* Instantiate a new HTTP object */
        Http http = new Http();

        /* Utilize HttpHelper to post HTTP callout with a text from slackJsonMessage
        Require Slack webhooks url (https://hooks.slack.com) to be added to Named Credentials */
        HttpRequest request = HttpHelper.prepareHttpRequest('callout:Slack_Webhooks/services/T0GJ0ACVB/BGLKW8JAW/5QHFXTcZH9rE5HFZnoovss5t', 'POST', slackJsonMessage);
        
        /* Return the response in HttpResponse object if any */
        HttpResponse response = http.send(request);

        return response;
    }

    /**
     * Checks org limits usage and post notification if needed
     * @param dangerLevelPercentage - define a level of sent emails which require dev team notification
     */
    public static void checkLimitsAndSendWebhook(Integer dangerLevelPercentage) {

        /* Instantiate a new object with a current value of single email org limits */
        OrgLims currentLimits = new OrgLims();

        /* Convert current limit usage to percentage */
        Decimal currentLevelPercentage = Decimal.valueOf(currentLimits.singleEmailValue).divide(currentLimits.singleEmailLimit, 4) * 100;

        /* Define formatted limit usage */
        String values = currentLimits.singleEmailValue + '/' + currentLimits.singleEmailLimit;

        /* Check if the critical level of sent emails was exceeded */
        if (currentLevelPercentage >= dangerLevelPercentage) {

            /* Instantiate a new object with a relevant message */
            SlackJson message = new SlackJson('<!here> `Achtung! Single Email Message Org Limits usage: ' + values + '`');

            /* Serialize SlackJson message */
            String slackJsonMessage = JSON.serialize(message);

            /* Call SlackPostCalloutAsync method to post a message */
            OrgLimitsSlackNotification.SlackPostCalloutAsync(slackJsonMessage);
        }
    }
}