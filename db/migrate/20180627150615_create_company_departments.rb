class CreateCompanyDepartments < ActiveRecord::Migration[4.2]
  def change
    create_table :company_departments do |t|
      t.string :name, index: true, null: false
      t.references :company, index: true, foreign_key: true, null: false
      t.boolean :active, default: true, index: true
      t.boolean :is_deleted, default: false, index: true
      t.integer :created_by_user_id, references: 'User', index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
