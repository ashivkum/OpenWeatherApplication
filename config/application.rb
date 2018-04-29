require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WeatherApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # We store this API_KEY as part of ENV variables so we don't expose any of this info to the user
    # This will NOT be committed to the repo in production in order to shield source code
    ENV['API_KEY'] = 'ed8333f08fee276026c2d1e8aa000902'

    ENV['BASE_WEATHER_URL'] = 'http://api.openweathermap.org/data/2.5/weather?q=%s&appId=%s'
  end
end
