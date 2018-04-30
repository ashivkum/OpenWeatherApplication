class CreateCountriesToCodeMapping < ActiveRecord::Migration[5.2]
  def change
    create_table "countries", id: false, force: :cascade do |t|
      t.string "country_name", limit: 255
      t.string "country_code", limit: 10
    end

    create_table "city_weathers", id: false, force: :cascade do |t|
      t.string "city", limit: 255
      t.string "country", limit: 255
      t.integer "temperature"
      t.integer "wind"
      t.string "wind_intensity", limit: 255
      t.integer "wind_direction"
      t.integer "pressure"
      t.integer "humidity"
      t.string "weather_description", limit: 255
      t.string "weather_main", limit: 255
      t.integer "last_requested_utc"
    end
  end
end
