class CreateReceiptEmailTemplates < ActiveRecord::Migration
  def change
    create_table :receipt_email_templates do |t|
      t.string :name, null:false
      t.datetime :datetime, null:false

      t.timestamps null: false
    end
  end
end
