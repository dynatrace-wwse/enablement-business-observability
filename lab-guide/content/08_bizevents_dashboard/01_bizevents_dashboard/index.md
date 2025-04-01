## Business Observability Dashboard

As part of this training we have provided a Business Observability dashboard to upload. 

This dashboard provides a comprehensive, real-time view of your business's key performance indicators (KPIs) and operational health, enabling data-driven decision-making and proactive problem-solving.  

This dashboard encompasses all of the training topics we covered today in a single view.  

The example dashboard is also meant to provide ideas for the Art of the Possible when working with Business Observability uses cases.

### Astroshop - Order to Shipped Business Observability Dashboard - Download

Download the dashboard `Astroshop - Order to Shipped Business Observability Dashboard` using the source file [Astroshop_-_Order_to_Shipped_Business_Observability_Dashboard.json](https://github.com/dynatrace-wwse/enablement-business-observability/blob/main/lab-guide/assets/Astroshop_-_Order_to_Shipped_Business_Observability_Dashboard.json) to your local system.

### Astroshop - Order to Shipped Business Observability Dashboard - Upload

Open the `Dashboards` app.

Select the `Upload` button and pick the Astroshop_-_Order_to_Shipped_Business_Observability_Dashboard.json from your local system.

![Dashboard Upload](../../../assets/images/08_01_dashboard_upload.png)

When the Astroshop_-_Order_to_Shipped_Business_Observability_Dashboard first loads a `Review all code` button appears.  

Select the `Review all code` button.

![Dashboard Review all Code 1](../../../assets/images/08_01_dashboard_review_all_code_1.png)

A `Review Code` box will appear.

Select the checkbox for "Always trust code in this document".

Then select the `Accept and run` button.

![Dashboard Review all Code 2](../../../assets/images/08_01_dashboard_review_all_code_2.png)

When uploaded,  you should see all tiles with data.

![Dashboard Review all Code 2](../../../assets/images/08_01_dashboard_astroshop_review_1.png)

### Enable IT ISSUES

Wait,  there is more fun!!

Go to your Astroshop UI browser tab.

In the url address bar, append the following to the end of the url.

```txt
/feature
```
Find the `paymentServiceUnreachable` and select the drop down to on.

Then select the `save` button.

![Astroshop Feature Flags](../../../assets/images/08_01_dashboard_astroshop_feature.png)

Note: Select this link [Astroshop/OpenTelemetry Demo App Feature Flags](https://opentelemetry.io/docs/demo/feature-flags/) for more details on the Feature Flags.

### IT ISSUES - Place Order Step

Within 10 minutes an IT Issue should be opened in the `Place Order` Step section of the dashboard.  You will need to refresh the dashboard as auto-refresh is turned off.   

![Place Order - IT Issue 1](../../../assets/images/08_01_dashboard_astroshop_review_it_issue_1.png)

Click the `IT` link in the drilldown section under the `Place Order` Step.  This will open the IT Problem that was automatically detected by the Davis AI.

![Place Order - IT Issue 1](../../../assets/images/08_01_dashboard_astroshop_review_it_issue_2.png)

### BUSINESS ISSUES - Place Order Step

![Place Order - Business Issue 1](../../../assets/images/08_01_dashboard_astroshop_review_business_issue_1.png)

Click the `Business` link in the drilldown section under the `Place Order` Step.  This will open the Business Problem that was generated from our previous lab, `Avg. duration` greater than 1 second for the `Astroshop - Order to Shipped` Business Process.

![Place Order - Business Issue 2](../../../assets/images/08_01_dashboard_astroshop_review_business_issue_2.png)

### SECURITY ISSUES - Place Order Step

![Place Order - Security Issue 1](../../../assets/images/08_01_dashboard_astroshop_review_security_issue_1.png)

Click the `Security` link in the drilldown section under the `Place Order` Step.  This will open all open vulnerabilities for the Astroshop-Frontend workload,  which supports `Place Order` Step of the Business Process.

![Place Order - Security Issue 2](../../../assets/images/08_01_dashboard_astroshop_review_security_issue_2.png)

### Conclusion

We have completed the hands on exercises for the training.  We will now move to the Wrap Up section.