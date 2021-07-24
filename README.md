# A Server Has No Name

Rails server for returning nearby breweries in Colorado. Leverages [OpenBreweryDB](https://www.openbrewerydb.org/#documentation).

## Running locally

Start up postgres and then run the following commands:

```
bundle install
bundle exec rake db:create db:migrate db:seed
bundle exec rails s
```

## Routes

Route for returning all breweries in Colorado, sorted by name in alphabetical order.
```
http://localhost:3000/breweries/all
```

Parameters:
None

Route for breweries in Colorado within a given distance of a point, sorted by distance.
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

Both routes return only JSON in the following response structure. Note that the `/breweries/all` route will omit the `distance` field from the JSON.

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

## Things to change

There are a bunch of things I'm not really happy with in this project, but haven't had the time to fix, because I have a full time job, a wife, a cat, and live in Colorado. 

1) Change the routes so this app server can retrieve breweries by state, probably something like '/breweries/colorado/' and '/breweries/colorado/search' which is more restful than what I have now in this project. I'd also create a separate controller for these routes, as it would be more conventional with rails.

2) Remove the extra generated stuff that rails added, like the action cable and haml.

3) Leverage redis/sidekiq for cache. The way I'm caching the open api response right now is perfect...for nosql. Would be great to just schedule sidekiq workers to save off the OpenAPI Brewery responses asynchronously so the user isn't waiting for those requests to finish. 

4) Leverage the timestamps on the Search table to ensure the cache isn't too stale. If one of those breweries that is pending gets added in a week, the user won't see it unless our database is cleared.

5) Do proper parameter validation. Right now it just checks for the presence of these parameters, but the route should throw a 400 when distance is negative, lat/long is invalid, strings given, etc.

6) Introduce tokens or other mechanisms to avoid DoS.

7) Improve code coverage. It's not great right now, I know. I also probably should mock out those Httparty requests, because they might block my IP and the data can change at any time and fail my tests!

8) Rename the github project and server. Didn't know what I was going to work on when I created the github project/rails project.

9) Need documentation with the classes/methods.

There are some other minor things I'd like to change that are commented in the project as well.
