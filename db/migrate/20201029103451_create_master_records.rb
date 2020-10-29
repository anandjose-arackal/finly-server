class CreateMasterRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :master_records do |t|
      t.integer :master_schema_id, index: true, foreign_key: true, references: 'master_schemas', null: false
      t.integer :parent_id, references: 'master_records', foreign_key: true, index: true
      t.datetime :start_date, index: true
      t.datetime :end_date, index: true
      t.integer :company_id, index: true, references: 'companies', foreign_key: true
      t.integer :created_by_id, index: true, references: 'users', foreign_key: true
      t.string :field_1, index: true
      t.string :field_2, index: true
      t.string :field_3, index: true
      t.string :field_4, index: true
      t.string :field_5, index: true
      t.string :field_6, index: true
      t.string :field_7, index: true
      t.string :field_8, index: true
      t.string :field_9, index: true
      t.string :field_10, index: true

      t.datetime :deleted_at, index: true
      t.timestamps index: true
    end
  end
end
