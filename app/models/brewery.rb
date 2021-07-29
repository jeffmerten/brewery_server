class Brewery
  include BrewerySerializer

  attr_accessor :json
  attr_accessor :id, :name, :type, :street, :city, :state, :zip, :latitude, :longitude, :phone, :website_url, :tags, :distance

  def initialize(json)
    @json = json
    @id = json['id']
    @name = json['name']
    @type = json['brewery_type']
    @street = json['street']
    @city = json['city']
    @state = json['state']
    @zip = json['postal_code']
    @latitude = json['latitude']
    @longitude = json['longitude']
    @phone = json['phone']
    @website_url = json['website_url']
    @tags = json['tag_list']
  end

  def valid?
    # The types from openbrewerydb are: micro, regional, brewpub, large, planning, bar, contract, proprietor
    # planning type is one that is not open yet.
    # bar is not currently returned, but will be evaluated later.
    return false if ['planning', 'bar'].include?(@type)

    # This project might not have a name, but the breweries we return in our API must have one.
    return false unless @name
    true
  end

  def self.within(distance, latitude, longitude)
    service = Service::OpenBreweryDb.new(distance: distance, latitude: latitude, longitude: longitude)
    service.retrieve_breweries.sort_by(&:distance)
  end
end
