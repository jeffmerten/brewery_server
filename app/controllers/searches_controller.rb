class SearchesController < ApplicationController

  def show
    unless params[:distance] && params[:latitude] && params[:longitude] # TODO: Use constraints/regex for this
      head 400
    else
      render_breweries
    end
  end

  private

  def render_breweries
    begin
      service = Service::OpenBreweryDb.new(params)
      breweries = service.retrieve_breweries
      if breweries.any?
        render json: breweries
      else
        head 204
      end
    rescue HTTParty::Error
      head 500
    end
  end
end
