class CreateSsoKeys < ActiveRecord::Migration[4.2]
  def change
    create_table :sso_keys do |t|
      t.string :xor_key
      t.string :sha512_key
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
