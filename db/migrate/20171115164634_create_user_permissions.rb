class CreateUserPermissions < ActiveRecord::Migration[4.2]
  def change
    create_table :user_permissions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :company, index: true, foreign_key: true
      t.boolean :create_beneficiaries

      t.timestamps null: false
    end
  end
end
