class CreateSignedupUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :signedup_users do |t|
      t.string :name
      t.string :mobile_number
      t.string :email
      t.string :encrypted_password
      t.string :products

      t.timestamps null: false
    end
  end
end
