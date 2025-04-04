## Business Alert

In this section of the lab we will create an alert for `Place Order` Business Events that have revenue = 0.

## Business Alert - OpenPipeline - Place Order

Launch the OpenPipeline app.

Select `Business events` in the OpenPipeline tree.

Select `Pipelines` tab.

Select the `Astroshop` Pipeline.

![Launch OpenPipeline](../../../assets/images/05_bizevents_metric_placeorder_openpipline_launch_a.png)

## Business Alert - OpenPipeline - Data extraction - Place Order

Select `Data extraction` tab.

Select the `+ Processor` button (left side of the screen), then select `Davis event`.

![Pipeline Part 1](../../../assets/images/06_bizevents_alert_open_pipeline_1.png)

Fill out the fields with the following data:

Name: 

```text
OrdersWithZeroValues
```

Matching condition: 

```text
event.provider == "astroshop" and event.type == "astroshop.placeorder.success" and revenue == 0
```

Event template: 

```text
Astroshop - Orders with Zero Values
```

Event description: 

```text
This can occur when data synchronization failures occur between the Astroshop inventory system and website. Please treat this a P1!
```

Event properties:

Davis events are enriched with additional fields, as detailed in the [Davis event model documentation](https://docs.dynatrace.com/docs/shortlink/semantic-dictionary-davis-ai#event).

```text
The event.type, event.name and event.description sections should be 
pre-filled from the previous entries you configured above.  

We will only change the event.type field.
```
Plese update the event.type field to use the following:

```text
Right side value:   ERROR_EVENT
```

Please add new entries for Event properties section using the following:

```text
Left side name:     dt.davis.timeout
Right side value:   10
```

```text
Left side:          dt.davis.is_merging_allowed 
Right side value:   true
```

```text

Left side name:     dt.source_entity 
Right side value:   {dt.entity.process_group}
```

Select the Save Button at the top right of the screen.

![Pipeline Part 2](../../../assets/images/06_bizevents_alert_open_pipeline_2.png)

### Conclusion

We have completed the `Place Order` Business Alert.  The next section will validate the data.

