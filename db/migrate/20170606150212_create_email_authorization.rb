class CreateEmailAuthorization < ActiveRecord::Migration
  def change
    create_table :email_authorizations do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :authorizable_id, index: true, null: false
      t.string :authorizable_type, index: true, null: false
      t.string :token
      t.boolean :is_valid, default: true
    end
  end
end
