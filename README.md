# Brewery Server

Rails server for returning nearby breweries by leveraging [OpenBreweryDB](https://www.openbrewerydb.org/#documentation).

## Running locally

Start up postgres and then run the following commands:

```
bundle install
bundle exec rake db:create db:migrate db:seed
bundle exec rails s
```