Rails.application.routes.draw do

  scope 'breweries/', controller: 'searches' do
    get 'search' => :show
    get 'all' => :show_all
  end

  # resources :searches
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
