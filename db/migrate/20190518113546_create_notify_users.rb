class CreateNotifyUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :notify_users do |t|
      t.integer :user_id
      t.integer :company_id
      t.integer :document_id
      t.string :document_type
      t.boolean :enabled

      t.timestamps
    end
  end
end
