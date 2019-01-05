class CreatePinCodeCityIdMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :pin_code_city_id_mappings do |t|
      t.string :pin_code
      t.string :city_id

      t.timestamps null: false
    end
  end
end
