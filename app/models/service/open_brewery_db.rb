require 'httparty'
require 'json'

module Service
  class OpenBreweryDb
    include DistanceHelper

    attr_accessor :params
    attr_accessor :latitude, :longitude, :search_distance

    def initialize(params = {})
      @params = params
      @latitude = params[:latitude]
      @longitude = params[:longitude]
      @search_distance = params[:distance] || '25'
    end

    def retrieve_breweries(show_all = false)
      all_breweries = []
      page_number = 0
      page_size = 50

      loop do
        page_number = page_number + 1
        response = retrieve_from_service(page_number, page_size)
        breweries = response.map do |brewery_json|
          Brewery.new(brewery_json)
        end

        all_breweries.concat(filtered_breweries(breweries, show_all))

        break if breweries.count < page_size

        if page_number * page_size > 1000
          # Colorado has a lot of breweries, but we know we've messed up in our code or open api choice if we're
          # returning more than a 1000 of them.
          raise 'Got 1000 breweries, something is wrong' # TODO probably want to configure this with an ENV variable
        end
      end

      sort_breweries(all_breweries, show_all)
    end

    private

    def sort_breweries(breweries, show_all)
      if show_all
        breweries.sort_by(&:name)
      else
        breweries.sort_by(&:distance)
      end
    end

    def retrieve_from_service(page_number, page_size)
      url = "https://api.openbrewerydb.org/breweries?by_state=colorado&page=#{page_number}&per_page=#{page_size}"
      search = Search.find_by(query: url)

      if search && search.response
        JSON.parse(search.response)
      else
        result = HTTParty.get(url)
        Search.create(query: url, response: result)
        result
      end
    end

    def show_brewery?(brewery, show_all)
      return false unless brewery.valid?
      return true if show_all

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

    def filtered_breweries(breweries, show_all)
      breweries.select do |brewery|
        show_brewery?(brewery, show_all)
      end
    end
  end
end