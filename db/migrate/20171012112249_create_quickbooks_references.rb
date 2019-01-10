class CreateQuickbooksReferences < ActiveRecord::Migration[4.2]
  def change
    create_table :quickbooks_references do |t|
      t.string :name
      t.references :company

      t.timestamps null: false
    end
  end
end
