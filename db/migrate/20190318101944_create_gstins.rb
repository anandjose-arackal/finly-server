class CreateGstins < ActiveRecord::Migration[5.2]
  def change
    create_table :gstins do |t|
      t.string :gstin
      t.string :legal_name_of_business
      t.string :state
      t.date :date_of_registration
      t.string :constitution_of_business
      t.string :taxpayer_type
      t.string :status
      t.text :api_response
      t.string :api_provider

      t.timestamps
    end
  end
end
