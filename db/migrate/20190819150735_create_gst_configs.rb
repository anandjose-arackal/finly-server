class CreateGstConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :gst_configs do |t|
      t.boolean :gst
      t.boolean :tds
      t.integer :company_id, references: "Company", index: true, foreign_key: true

      t.timestamps
    end
  end
end
