class CreateAdminIntegrationRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_implementation_requests do |t|
      t.integer :company_id, foreign_key: true, index: true, null: false, references: 'companies'
      t.integer :admin_user_id, foreign_key: true, index: true, null: false, references: 'admin_users'
      t.string :request_key, index: true, null: false
      t.text :request_params, limit: 4294967295
      t.string :master
      t.string :name
      t.integer :status, index: true, null: false
      t.text :message
      t.datetime :started_at
      t.datetime :completed_at
      t.decimal :runtime
      t.integer :requested_items
      t.integer :completed_items
      t.attachment :request_file
      t.attachment :result_file

      t.timestamps
    end
  end
end
