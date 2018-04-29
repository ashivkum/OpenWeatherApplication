class CreateCountriesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :countries, :primary_key => :country_name, :id => false do |t|
        t.string :country_name, :limit => 255
        t.string :country_code, :limit => 10
    end
  end
end
