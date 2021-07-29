# Brewery Server

Rails server for returning nearby breweries by leveraging [OpenBreweryDB](https://www.openbrewerydb.org/#documentation).

## System Requirements
- Ruby 2.6.8
- PostgreSQL 9.0+
- PostGIS 2.4+

## Running locally

Start up postgres and then run the following commands:

```
bundle install
bundle exec rake db:create db:migrate
bundle exec rails s
```

**NOTE**
The activerecord-postgis-adapter should attaching the PostGIS extension to your database, but if there are problems, the following commands can be run to reset the database and to attach PostGIS manually:
```
rake db:migrate:reset
rake db:gis:setup
```

## Running tests

To run tests, run the following command:
```
bundle exec rspec spec
```

## Routes

Route for breweries within a given distance of a point, sorted by distance.
```
http://localhost:3000/breweries/search?latitude=40.0190131&longitude=-105.2752297&distance=10
```

### Request Parameters

|Name     |Type | Description           | Example   |
|---------|-----|-----------------------|-----------|
|latitude |float|latitude of point      |40.0190131 |
|longitude|float|longitude of point     |-105.2752  |
|distance |float|radius to search(miles)|10.5       |

### Response structure

```
[
  {
    "id": 1460,
    "name": "Mountain Sun Pub and Brewery",
    "type": "brewpub",
    "street": "1535 Pearl St",
    "city": "Boulder",
    "zip": "80302-5408",
    "latitude": "40.0190131",
    "longitude": "-105.2752277",
    "phone": "3035460886",
    "distance": 0.0001058276322217181,
    "websiteUrl": "http://www.mountainsunpub.com"
  },
  {
    "id": 1584,
    "name": "The Post Brewing Co",
    "type": "brewpub",
    "street": "2027 13th St",
    "city": "Boulder",
    "zip": "80302-5201",
    "latitude": "40.0184764897959",
    "longitude": "-105.278894204082",
    "phone": "7203723341",
    "distance": 0.1974164935240559,
    "websiteUrl": "http://www.postbrewing.com"
  },
  {
    "id": 1249,
    "name": "Boulder Beer On Walnut",
    "type": "brewpub",
    "street": "1123 Walnut St",
    "city": "Boulder",
    "zip": "80302-5116",
    "latitude": "40.0168555",
    "longitude": "-105.2804375",
    "phone": "3034471345",
    "distance": 0.3133078605885724,
    "websiteUrl": ""
  }
]
```

## How it works
The OpenBrewery API is an open service with no authentication, thus subject to downtime or performance issues. In order to mitigate these concerns, this server does the following:

1) Any request that hits the brewery server will first hit the cache using the lat/lon coordinates, leveraging PostGIS to achieve efficiency. 
2) The result for this query will be compared with the request parameters to determine if the search area requested is completely within the cached result. If this is case, the cached result will be leveraged and any results that are not applicable will be filtered down before the JSON response to returned to the client.
3) If the closest result is not a complete match, a service call will be made to the OpenBrewery API that contains the lat/lon from the request parameters as well. Service requests will be made until the results are at or above the requested search radius.
4) The fetched result from the OpenAPI will be saved to the database along with the appropriate radius from the result set along with the original lat/lon. If the previous result was a subset of this result, that prior result will be deleted.

## Things to improve on
1) Test coverage is very sparse right now. The following should be added as scenarios and assertions:
  - Cache hits within search radius
  - Cache misses/failures
  - Assertions on the service requests made, including paged results
2) If the requested search is a superset of the retrieved cache result, the previous cached result should be deleted once the fetched search results are all retrieved. 
3) Memcache can be leveraged to improve response times. 
4) The SQL statements can likely be further optimized. Additionally cached results from 2+ regions could potentially contain the requested search region. 