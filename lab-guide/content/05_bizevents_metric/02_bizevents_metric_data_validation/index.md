## Data Validation

In this section of the lab we will validate the data for the `Place Order` metric.   We also want to see it broken out by country.

### Query Business Events in Dynatrace

Using the Notebook's App, execute the below DQL query, which retrieves the buisness event metric `bizevents.astroshop.placeorder.success`.  

DQL:
```sql
timeseries placeorder.success = sum(bizevents.astroshop.placeorder.success), by:{country}
```
Result:

![DQL Query](../../../assets/images/05_bizevents_metric_place_order_data_validation.png)

### Conclusion

We have completed the Business Event metric data validation for the `Place Order` metric.