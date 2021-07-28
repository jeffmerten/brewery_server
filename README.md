# Brewery Server

Rails server for returning nearby breweries by leveraging [OpenBreweryDB](https://www.openbrewerydb.org/#documentation).

## Running locally

Start up postgres and then run the following commands:

```
bundle install
bundle exec rake db:create db:migrate db:seed
bundle exec rails s
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

Parameters
|Name     |Type | Description       | Example   |
|---------|-----|-------------------|-----------|
|latitude |float|latitude of point  |40.0190131 |
|longitude|float|longitude of point |-105.2752  |
|distance |float|radius to search in|10.5       |

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
The OpenBrewery API is an open service with no authenication, thus subject to downtime or performance issues. In order to mitigate these concerns, this server does the following:

1) Any request that hits the brewery server will first hit the cache using the lat/lon coordinates, leveraging PostGIS to achieve efficiency. 
2) The result for this query will be compared with the request parameters to determine if the search area requested is completely within the cached result. If this is case, the cached result will be leveraged and any results that are not applicable will be filtered down before the JSON response to returned to the client.
3) If the closest result is not a complete match, a service call will be made to the OpenBrewery API that contains the lat/lon from the request parameters as well. Service requests will be made until the results are at or above the requested search radius.
4) The fetched result from the OpenAPI will be saved to the database along with the appropriate radius from the result set along with the original lat/lon. If the previous result was a subset of this result, that prior result will be deleted.
