PageView = Backbone.View.extend({
  el: 'body',
  model: Backbone.Model,

  events: {
    'change select.form-control': 'handleCountryChange',
    'keyup input.form-control': 'handleCityChange',
    'click .submit-button': 'renderWeather'
  },

  template: _.template(
    ['<option class="country" data-value=<%= modelId %> data-country-code=<%= code %>>',
      '<%= text %>',
      '</option>'
    ].join('\n')),

  initialize: function(options) {
    this.countriesList = new CountriesCollection();
    this.locationModel = new Backbone.Model({country: 'AF', city: ''});
    this.weatherModel = new WeatherModel(null, {
      city: '',
      country: 'AF'
    });
    this.weatherView = new WeatherView({ model: this.weatherModel });
    this.countriesList.fetch().done(function(response) {
      this.render();
    }.bind(this)).fail(function(error) {
      throw 'Failed to retrieve list of countries!';
    });
  },

  handleCityChange: function(e) {
    var cityValue = $(e.currentTarget).val();
    this.locationModel.set('city', cityValue);
    this.weatherModel.setModelUrl({
      city: cityValue,
      country: this.locationModel.get('country')
    })
  },

  handleCountryChange: function(e) {
    var countryValue = $(e.currentTarget).find('option:selected').data('country-code');
    this.locationModel.set('country', countryValue);
    this.weatherModel.setModelUrl({
      city: this.locationModel.get('city'),
      country: countryValue
    });
  },

  render: function() {
    this.countriesList.each(function(countryModel) {
      var htmlTemplate = this.template({
        code: countryModel.get('country_code'),
        text: countryModel.get('country_name'),
        modelId: countryModel.cid
      });
      this.$el.find('.form-control').append(htmlTemplate);
    }.bind(this));
  },

  renderWeather: function() {
    this.weatherModel.fetch().done(function(response) {
      this.weatherView.render();
    }.bind(this));
  }

});