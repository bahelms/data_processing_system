# DPS

Processes streaming data from a message broker.

#### Message Example -- JSON   

{
  "table": "sycclass",
  "record_identity": "uuid",
  "record_timestamp": "...",
  "record_mode": "insert",
  "scdlcd": null,
  "sccscl": "031",
  "scclgp": "04",
  "scclds": "description",
  "scclst": "sort"
}

## TODO  
* Add constraints to DB table creation (primary key, not null, foreign key)

