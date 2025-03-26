## Data Validation

In this section of the lab we will validate the data for the `Order Shipped` step of the `Order to Shipped` business process.

### Query Business Events in Dynatrace

Using a Notebook execute the below DQL query which retrieves the business events for `astroshop.ordershipped.success` step.  

DQL:
```sql
fetch bizevents
| filter event.provider == "astroshop" and event.type == "astroshop.ordershipped.success"
| fields timestamp, event.provider, event.type, orderId
| sort timestamp desc
```

Result:

![DQL Query](../../../assets/images/04_bizevents_api_ordershipped_data_validation_dql.png)

### Conclusion

We have completed data validation for the `Order Shipped` step of the `Order to Shipped` business process.