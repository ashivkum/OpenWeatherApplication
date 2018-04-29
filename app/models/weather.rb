require 'pry'
require 'net/http'
require 'json'

class Weather
    @@CONVERSION_FACTOR = 1.8
    @@KELVIN_FACTOR = 273.15
    @@FARENHEIT_FACTOR = 32

    # Approximate conversion factor m/s to mph, taken from Google
    @@WIND_CONVERSION_FACTOR = 2.23694

=begin
The following methods handle the external dependencies and are just
wrappers for testing
=end

    def _sanitize_input(city, country)
        return city.upcase, country.upcase
    end

    def _setup_http_request(url)
        return URI.parse(url)
    end

    def _make_http_request(url_object)
        return Net::HTTP::get(url_object)
    end

    def _parse_json_payload(response_text)
        return JSON.parse(response_text)
    end


=begin
This method is a partial implementation of the Beaufort scale description
for winds, taken from https://en.wikipedia.org/wiki/Beaufort_scale#Modern_scale
=end

    def _get_beaufort_scale_verbiage(speed)
        if speed < 1 then
            return 'calm'
        elsif speed >= 1 && speed <= 4 then
            return 'light air'
        elsif speed > 4 && speed <= 8 then
            return 'light breeze'
        elsif speed > 8 && speed <= 13 then
            return 'gentle breeze'
        elsif speed > 13 && speed <= 19 then
            return 'moderate breeze'
        elsif speed > 19 && speed <= 25 then
            return 'fresh breeze'
        elsif speed > 25 && speed <= 32 then
            return 'strong breeze'
        else
            return 'high winds'
        end
    end

=begin
The following are math methods that help convert certain metrics to imperial
units      
=end

    def _kelvin_to_farenheit(kelvin)
        celsius = kelvin - @@KELVIN_FACTOR
        return ((@@CONVERSION_FACTOR * celsius) + @@FARENHEIT_FACTOR).round
    end

    def _meter_per_second_to_mph(wind_speed)
        return (wind_speed * @@WIND_CONVERSION_FACTOR).round
    end


=begin
This is where the main computation is done
=end

    def get_weather_response(city, country)
        sanitized_city, sanitized_country = _sanitize_input(city, country)

        # Generate the URL from the requested city and country, and the API key
        query_string = '%s,%s' % [sanitized_city, sanitized_country]
        request_url = ENV['BASE_WEATHER_URL'] % [query_string, ENV['API_KEY']]

        # Get the URL request object from the requested url
        url_request = _setup_http_request(request_url)

        # Make the HTTP URL request
        response_text = _make_http_request(url_request)

        # Parse the response
        response_payload = JSON.parse(response_text)

        if response_payload['cod'].to_i == 404 then
            raise ActiveRecord::RecordNotFound.new('City was not found!')
        end

        farenheit_temperature = _kelvin_to_farenheit(response_payload['main']['temp'])
        wind_speed_mph = _meter_per_second_to_mph(response_payload['wind']['speed'])
        beaufort_scale_verbiage = _get_beaufort_scale_verbiage(wind_speed_mph)

        return {
            :city => response_payload['name'],
            :temperature => farenheit_temperature,
            :wind => wind_speed_mph,
            :wind_intensity => beaufort_scale_verbiage,
            :wind_direction => response_payload['wind']['deg'],
            :pressure => response_payload['main']['pressure'],
            :humidity => response_payload['main']['humidity'],
            :weather_description => response_payload['weather'][0]['description'],
            :weather_main => response_payload['weather'][0]['main'],
            :last_requested_utc => Time.now.utc.to_i
        }
    end
end