## Business Flow
  
In this section of the lab we will create a Business Flow using the Business Events we have defined for the Astroshop `Order to Shipped` business process.


## Business Flow - OpenPipeline - Place Order

1. Launch the Business Flow app

2. Select `+ Business Flow ` to get to the configuration page

![Business Flow Config 1](../../../assets/images/06_bizevents_business_flow_config_1.png)

3. Select the Pencil icon at the top left and rename the Configuration using the following:

Name:

```txt
Astroshop - Order to Shipped
```

Select the Save button.

![Business Flow Config 2](../../../assets/images/06_bizevents_business_flow_config_2.png)

4. In the `Correlation ID` section use the following:

```txt
orderId
```

![Correlation ID](../../../assets/images/06_bizevents_business_flow_config_correlationid.png)

5. For Flow Step 1, use the following:

Name:

```txt
Place Order
```

Drop-down event box:

```txt
astroshop.placeorder.success
```

![Flow Step 1](../../../assets/images/06_bizevents_business_flow_config_step1.png)

After picking `astroshop.placeorder.success`, the `Place Order` step should look like this below:

![Flow Step 1](../../../assets/images/06_bizevents_business_flow_config_step1_b.png)


5. For Flow Step 2, click the `Place Order` step.  Select the + button on the bottom.  This will add a new step under the `Place Order` step. Use the following:

Name:

```txt
Fraud Check
```

Drop-down event box:

```txt
astroshop.fraudcheck.success
```

![Flow Step 2](../../../assets/images/06_bizevents_business_flow_config_step2.png)

After picking `astroshop.fraudcheck.success`, the `Fraud Check` step should look like this below:

![Flow Step 2](../../../assets/images/06_bizevents_business_flow_config_step2_b.png)

5. For Flow Step 3, click the `Fraud Check` step.  Select the + button on the bottom.  This will add a new step under the `Fraud Check` step.  Use the following:

Name:

```txt
Order Shipped
```

Drop-down event box:

```txt
astroshop.ordershipped.success
```

![Flow Step 3](../../../assets/images/06_bizevents_business_flow_config_step3.png)

After picking `astroshop.ordershipped.success`, the `Order Shipped` step should look like this below:

![Flow Step 2](../../../assets/images/06_bizevents_business_flow_config_step3_b.png)

6. For the KPI is extracted from the event to calculate revenue section, use the following:

Mapping event dropdown list pick:

```txt
astroshop.placeorder.success
```

Mapping attribute from event dropdown list pick:

```txt
revenue
```

![KPI](../../../assets/images/06_bizevents_business_flow_config_kpi.png)

7. Select the `Validate & Save` button at the top right of the page

![Validate and Save](../../../assets/images/06_bizevents_business_flow_config_save.png)

8. Select the `View flow` button at the top right of the page

![View Flow](../../../assets/images/06_bizevents_business_flow_config_viewflow.png)

### Conclusion

We have completed the Business Flow configuration for the Astroshop `Order to Shipped` business process. The next section will validate the data.