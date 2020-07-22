class CreateErpSyncs < ActiveRecord::Migration[5.2]
  def change
    create_table :erp_sync_attempts do |t|
      t.integer :record_id, index: true, null: false
      t.string :record_type, index: true, null: false
      t.integer :status_id, index: true, references: 'erp_sync_statuses', foreign_key: true, null: false
      t.integer :company_id, index: true, references: 'companies', foreign_key: true, null: false
      t.integer :macro_id, index: true
      t.integer :macro_job_id, index: true
      t.string :message
      t.string :reference_id
      t.datetime :attempted_at, null: false
      t.datetime :deleted_at, index: true

      t.timestamps null: false, index: true
    end
    add_index :erp_sync_attempts, [:record_id, :record_type]
  end
end
