## Data Validation

In this section of the lab we will validate the data for `Placer Order Success` step of the `Order to Shipped` business process.

### Query Business Events in Dynatrace

In the Notebook App, execute the below DQL query, which retrieves the buisness events for `astroshop.placeorder.success` step.  

DQL:
```sql
fetch bizevents
| filter event.provider == "astroshop" and event.type == "astroshop.placeorder.success"
| fields timestamp, event.provider, event.type, userId, email, orderId, shippingTrackingId, trace_id
| sort timestamp desc
```

Result:

![DQL Query](../../../assets/images/02_bizevents_oneagent_placeorder_success_dql.png)