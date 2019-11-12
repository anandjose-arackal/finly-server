class CreateUsersWithGroupMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :users_with_group_mappings do |t|
      t.integer :user_id, foreign_key: true, references: 'User'
      t.integer :company_id, foreign_key: true, references: 'Company'
      t.integer :group_id, foreign_key: true, references: 'CompanyGroup'
    end

    add_index :users_with_group_mappings, :user_id
    add_index :users_with_group_mappings, :company_id
    add_index :users_with_group_mappings, :group_id
  end
end
