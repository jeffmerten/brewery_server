module BrewerySerializer
  def as_json(_options)
    {
      id: @id,
      name: @name,
      type: @type,
      street: @street,
      city: @city,
      zip: @zip,
      latitude: @latitude,
      longitude: @longitude,
      phone: @phone,
      distance: @distance,
      websiteUrl: @website_url
    }.compact
  end
end