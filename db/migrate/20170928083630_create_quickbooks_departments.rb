class CreateQuickbooksDepartments < ActiveRecord::Migration[4.2]
  def change
    create_table :quickbooks_departments do |t|
      t.string :name
      t.integer :quickbooks_id
      t.boolean :active
      t.references :company, index: true, foreign_key: true
      t.text :additional_information

      t.timestamps null: false
    end
  end
end
