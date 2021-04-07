class CreateEmailBodies < ActiveRecord::Migration[6.0]
  def change
    ActiveRecord::Base.connection.execute("TRUNCATE emails")
    remove_column :emails, :body rescue nil
    create_table :email_bodies do |t|
      t.integer :company_id, references: 'companies', index: true, foreign_key: true
      t.integer :email_id, references: 'emails', null: false, index: true, foreign_key: true
      t.text :body, limit: 4294967295
      t.datetime :deleted_at, index: true

      t.timestamps null: false, index: true
    end
  end
end
