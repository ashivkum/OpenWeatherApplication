WeatherView = Backbone.View.extend({
  el: '.weather-container',
  windDescriptionTemplate: _.template([
    '<div class="weather-header">',
    'Weather for <%= city %>',
    '</div>',
    '<div class="weather-description">',
    '<%= weatherDescription%> and <%= windIntensity%>, winds from the <%= windSymbolicDirection %> at <%= windSpeed %>mph',
    '</div>',
    '<div class="humidity-and-pressure">',
    '<div class="humidity">Humidity: <%= humidity %>%</div>',
    '<div class="pressure">Pressure: <%= pressure %> millibars</div>',
    '</div>',
    '<div class="current-temperature"><%= temperature %>&#176;F</div>'
  ].join('\n')),
  errorDescriptionTemplate: _.template([
    '<div class="error-container">',
    '<div class="error-msg"><%= message %></div>',
    '<img class="error-img" src=<%= srcUrl %>></img>',
    '</div>'
  ].join('\n')),

  baseDiv: [
      '<div class="current-weather">',
      '</div>'
  ].join('\n'),
  table_row: _.template([
      '<th class=<%= key %>><%= clean_key %></th>',
      '<td class=<%= value %>><%= clean_value %></th>'
  ].join('\n')),
  initialize: function(options) {
      this.model = options.model;
  },

  getWindDirectionVerbiage: function() {
      var windDirection = this.model.get('wind_direction');

      /* This logic is taken from http://tamivox.org/dave/compass/index.html in order
       * to generate the correct verbiage
       *
       * Messy logic I know, but I'm trying
       */

      if (windDirection >= 348.76 && windDirection <= 11.25) {
        return 'N';
      } else if (windDirection >= 11.26 && windDirection <= 33.75) {
        return 'NNE';
      } else if (windDirection >= 33.76 && windDirection <= 56.25) {
        return 'NE';
      } else if (windDirection >= 56.26 && windDirection <= 78.75) {
        return 'ENE';
      } else if (windDirection >= 78.76 && windDirection <= 101.25) {
        return 'E'
      } else if (windDirection >= 101.26 && windDirection <= 123.75) {
        return 'ESE';
      } else if (windDirection >= 123.76 && windDirection <= 146.25) {
        return 'SE';
      } else if (windDirection >= 146.26 && windDirection <= 168.75) {
        return 'SSE';
      } else if (windDirection >= 168.76 && windDirection <= 191.25) {
        return 'S';
      } else if (windDirection >= 191.26 && windDirection <= 213.75) {
        return 'SSW';
      } else if (windDirection >= 213.76 && windDirection <= 236.25) {
        return 'SW';
      } else if (windDirection >= 236.26 && windDirection <= 258.75) {
        return 'WSW';
      } else if (windDirection >= 258.76 && windDirection <= 281.25) {
        return 'W';
      } else if (windDirection >= 281.26 && windDirection <= 303.75) {
        return 'WNW';
      } else if (windDirection >= 303.76 && windDirection <= 326.25) {
        return 'NW';
      } else {
        return 'NNW';
      }
  },

  getWeatherDescriptionDiv: function() {
    var temperature = this.model.get('temperature');
    var weatherDescription = this.model.get('weather_description');
    weatherDescription = weatherDescription[0].toUpperCase() + weatherDescription.substr(1);
    var city = this.model.get('city');
    var windIntensity = this.model.get('wind_intensity');
    var windSpeed = this.model.get('wind');
    var humidity = this.model.get('humidity');
    var pressure = this.model.get('pressure');
    var windSymbolicDirection = this.getWindDirectionVerbiage();
    return this.windDescriptionTemplate({
      city,
      weatherDescription,
      windIntensity,
      windSpeed,
      windSymbolicDirection,
      humidity,
      pressure,
      temperature
    });
  },

  renderErrorView: function(requestedCity, code) {
    var message = '';
    $('.weather-container').html(this.baseDiv);
    if (code === 404) {
      message = 'Cannot find the city ' + requestedCity + '!';
    }
    if (code === 500) {
      message = 'A server error occured.  Please contact the webmaster';
    }
    $('.current-weather').append(this.errorDescriptionTemplate({
      message,
      srcUrl: '/assets/404-image.jpg'
    }));
  },

  render: function() {
      // Render the base table first
      $('.weather-container').html(this.baseDiv);

      // Generate the city that you are in
      $('.current-weather').append(this.getWeatherDescriptionDiv());
  }
});