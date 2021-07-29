class SearchesController < ApplicationController

  def show
    unless params[:distance] && params[:latitude] && params[:longitude] # TODO: Use constraints/regex for this
      head 400
      return
    end

    breweries = Brewery.within(params[:distance], params[:latitude], params[:longitude])
    if breweries.any?
      render json: breweries
    else
      head 204
    end
  end

end
