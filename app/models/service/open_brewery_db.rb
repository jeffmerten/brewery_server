require 'httparty'
require 'json'

module Service
  class OpenBreweryDb
    include DistanceHelper

    attr_accessor :params
    attr_accessor :latitude, :longitude, :search_distance

    def initialize(params = {})
      @params = params
      @latitude = params[:latitude].to_f
      @longitude = params[:longitude].to_f
      dist = params[:distance] || '25'
      @search_distance = dist.to_f
    end

    def retrieve_breweries
      breweries = retrieve_from_service
      all_breweries = filtered_breweries(breweries)
      all_breweries.sort_by(&:distance)
    end

    private

    def max_radius_from_results(results, lat, lon)
      max_radius = 0
      results.each do |brewery|
        brewery_lat = brewery["latitude"].to_f
        brewery_lon = brewery["longitude"].to_f
        distance = distance_between(lat, brewery_lat, lon, brewery_lon)
        max_radius = distance if distance > max_radius
      end
      max_radius
    end

    def retrieve_from_service

      # TODO: Fix this so it queries the closest based on the lat/lon parameters
      search = Search.first

      # TODO: Check if the search parameters are within cached result
      if search && search.response
        cached_response = JSON.parse(search.response)
        breweries = cached_response.map do |brewery_json|
          Brewery.new(brewery_json)
        end
        breweries
      else
        page_number = 0
        page_size = 50
        pagnitation_limit = 5
        distance_param = "#{@latitude},#{@longitude}"
        all_results = []
        max_rad = 0

        loop do
          page_number = page_number + 1
          url = "https://api.openbrewerydb.org/breweries?by_dist=#{distance_param}&page=#{page_number}&per_page=#{page_size}"
          results = HTTParty.get(url)

          all_results.concat(results)

          max_rad = max_radius_from_results(results, @latitude, @longitude)

          break if results.count < page_size || page_number > pagnitation_limit || max_rad > @search_distance
        end

        location = "POINT(#{@longitude} #{@latitude})"
        Search.create(response: all_results.to_json, lonlat: location, radius: max_rad)
        breweries = all_results.map do |brewery_json|
          Brewery.new(brewery_json)
        end

        breweries
      end
    end

    def show_brewery?(brewery)
      return false unless brewery.valid?

      if brewery.latitude && brewery.longitude
        distance = distance_between(@latitude, brewery.latitude.to_f, @longitude, brewery.longitude.to_f)
        if distance <= @search_distance.to_f
          brewery.distance = distance # I really don't like how this method is setting this, not too obvious. Need to change this later...
          true
        end
      else
        false
      end
    end

    def filtered_breweries(breweries)
      breweries.select do |brewery|
        show_brewery?(brewery)
      end
    end
  end
end
