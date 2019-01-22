class CreateCityICityCodeMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :city_id_city_code_mappings do |t|
      t.string :city_id
      t.string :city_code

      t.timestamps null: false
    end
  end
end
