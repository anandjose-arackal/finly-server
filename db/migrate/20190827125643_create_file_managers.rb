class CreateFileManagers < ActiveRecord::Migration[5.2]
  def change
    create_table :export_requests do |t|
      t.string :model_class, index: true
      t.string :export_name, index: true
      t.integer :export_template_id, index: true, null: false
      t.attachment :file
      t.datetime :scheduled_on, index: true
      t.datetime :expires_on, index: true
      t.integer :user_id, index: true, null: false, foreign_key: true, references: 'users'
      t.integer :company_id, index: true, null: false, foreign_key: true, references: 'companies'

      t.timestamps
    end
  end
end
