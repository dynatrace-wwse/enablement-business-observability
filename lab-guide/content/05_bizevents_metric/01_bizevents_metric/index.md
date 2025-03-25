## Place Order Metric

In this section of the lab we will create a count metric for `Place Order` step.  We also want to report by Country.

## Business Metric - OpenPipeline - Place Order

1. Launch the OpenPipeline app

2. Select `Business events` in the OpenPipline tree

3. Select `Pipelines` tab

4. Select the `Astroshop` Pipeline

![Launch OpenPipeline](../../../assets/images/05_bizevents_metric_placeorder_openpipline_launch_a.png)

## Business Metric - OpenPipeline Processing - Place Order


1. Select the `Metric Extraction` tab

2. Select the `+ Processor` button on the left and select `Counter metric`

![Pipeline Processing Rule Part 1](../../../assets/images/05_bizevents_metric_placeorder_openpipline_rule_1_a.png)

`Note`: 

* `Counter metric` 

```text
Where you want to only count the number `Place Order` occurrences.
```

* `Value metric` 

```text
Where you want to report on `Revenue`. The revenue field captured in the `Place Order` 
Business Event data would be extracted and used as the metric value. 
```

3. Fill out the fields with the following data:

Name: 

```text
OrderShippedSucccess
```

Matching condition: 

```text
event.provider == "astroshop" and event.type == "astroshop.placeorder.success"
```

Dimensions: 

Select the Custom radio button.

For both `Field name on record` and `Dimension name` sections use:

```text
country
```

Click the `Add dimension` button.  This will add both fields. 

4. Select the Save Button at the top right of the screen

![Pipeline Processing Rule Part 2](../../../assets/images/05_bizevents_metric_placeorder_openpipline_rule_2.png)

### Conclusion

We have completed the Business Metric capture for `Placer Order` step  of the `Order to Shipped` business process.  In the next section we will validate the data using the `Notebook's App`.