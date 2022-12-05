class CreateImportRecordStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :import_record_statuses do |t|
      t.string :name, index: true, null: false
      t.datetime :deleted_at, index: true

      t.timestamps null: false, index: true
    end
  end
end
