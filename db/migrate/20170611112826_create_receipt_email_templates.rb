class CreateReceiptEmailTemplates < ActiveRecord::Migration
  def change
    create_table :receipt_email_templates do |t|
      t.string :name, null:false
      t.integer :default_currency_id, references: 'Currency', index: true, foreign_key: true, null:false

      t.timestamps null: false
    end
  end
end
