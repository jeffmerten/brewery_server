class SearchesController < ApplicationController

  def show
    unless params[:distance] && params[:latitude] && params[:longitude] # TODO: Use constraints/regex for this
      head 400
    else
      render_breweries(false)
    end
  end

  def show_all
    render_breweries(true)
  end

  private

  def render_breweries(show_all)
    begin
    service = Service::OpenBreweryDb.new(params)
    breweries = service.retrieve_breweries(show_all)
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
