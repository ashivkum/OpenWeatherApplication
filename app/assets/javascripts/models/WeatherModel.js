WeatherModel = Backbone.Model.extend({
    urlTemplate: _.template('/weather/<%= city %>/<%= country %>'),
    url: '/weather',
    defaults: {
        city: '',
        temperature: null,
        wind: null,
        wind_intensity: null,
        wind_direction: null,
        pressure: null,
        humidity: null,
        weather_description: '',
        weather_main: '',
        last_requested_utc: -1
    },
    initialize: function(attributes, options) {
        this.setModelUrl(options);
    },

    sanitizeInput: function(options) {
        var city = options.city.replace(/\s+/g, ' ').trim().toUpperCase();
        var country = options.country.toUpperCase();
        return { city, country };
    },

    setModelUrl: function(options) {
        var sanitizedInput = this.sanitizeInput(options);
        this.url = this.urlTemplate({
            city: sanitizedInput.city,
            country: sanitizedInput.country
        });
    }
});