require 'net/http'
require 'json'

class WeatherController < ApplicationController
    def index
    end

    def fetch_weather_information
        weather_object = Weather.new
        response_payload = {}

        # Prepare and make the request
        begin
            response_payload = weather_object.get_weather_response(params[:city], params[:country])
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

    def countries
        all_countries = Countries.all
        render :json => all_countries
    end
end