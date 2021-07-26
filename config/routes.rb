Rails.application.routes.draw do
  scope 'breweries/', controller: 'searches' do
    get 'search' => :show
  end
end
