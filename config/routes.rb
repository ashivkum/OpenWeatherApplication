Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'weather#index'
  get '/countries', to: 'weather#countries'
  get '/weather/:city/:country', to: 'weather#fetch_weather_information'
end
