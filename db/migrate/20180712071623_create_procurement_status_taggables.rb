class CreateProcurementStatusTaggables < ActiveRecord::Migration
  def change
    create_table :procurement_status_taggables do |t|
      t.references :procurement, index: true, foreign_key: true
      t.references :status_tag, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
