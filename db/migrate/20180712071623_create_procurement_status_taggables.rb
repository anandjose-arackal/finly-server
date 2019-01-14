class CreateProcurementStatusTaggables < ActiveRecord::Migration[4.2]
  def change
    create_table :procurement_status_taggables do |t|
      t.references :procurement, index: true, foreign_key: true
      t.references :status_tag, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
