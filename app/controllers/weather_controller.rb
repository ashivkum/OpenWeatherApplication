require 'net/http'
require 'json'

class WeatherController < ApplicationController
    @@TIME_LIMIT = 600
    def index
    end

    def fetch_weather_information
        # First, see if the city to fetch is cached in DB and the last time it was cached was < 10 min ago
        # We are using 10 minutes as the caching time because that is what the API spec recommended weather
        # requests for a city be spaced out at.
        city_to_fetch = params[:city]
        weather_info = CityWeathers.find_by(:city => city_to_fetch)

        # If we already have that info cached, and last request was < 10 minutes ago, serve from our DB
        if weather_info && (Time.now.utc.to_i - weather_info[:last_requested_utc] < @@TIME_LIMIT) then
            render :json => weather_info
        else
            weather_object = Weather.new
            response_payload = {}

            # Prepare and make the request
            begin
                response_payload = weather_object.get_weather_response(params[:city], params[:country])

                # If the weather info was requested more than 10 minutes ago, update our entry in the DB
                if (weather_info != nil) then
                    response_payload[:city].upcase!
                    weather_info.update(response_payload)

                # If we never requested the city before, create the entry in the DB
                else
                    response_payload[:city].upcase!
                    CityWeathers.create(response_payload)
                end
                render :json => response_payload, :status => 200
            rescue URI::InvalidURIError
                render :json => { :error => 'Invalid URL was requested', :status => 400 },
                :status => 400
            rescue JSON::ParserError
                render :json => { :error => 'Invalid JSON was returned from the API', :status => 500 },
                :status => 500
            rescue ActiveRecord::RecordNotFound
                render :json => { :error => 'The place you were looking for could not be found!', :status => 404 },
                :status => 404
            end
        end
    end

    def countries
        all_countries = Countries.all
        render :json => all_countries
    end
end