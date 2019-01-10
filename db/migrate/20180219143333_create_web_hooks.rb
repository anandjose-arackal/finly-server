class CreateWebHooks < ActiveRecord::Migration[4.2]
  def change
    create_table :web_hooks do |t|
      t.text :url, null: false
      t.string :secret
      t.integer :created_by_user_id, foreign_key: true, index: true, references: 'User', null: false
      t.integer :company_id, foreign_key: true, index: true, references: 'Company', null: false
      t.boolean :is_deleted, default: false, index: true

      t.timestamps null: false
    end
  end
end
