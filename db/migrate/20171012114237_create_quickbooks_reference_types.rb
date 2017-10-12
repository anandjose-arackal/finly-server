class CreateQuickbooksReferenceTypes < ActiveRecord::Migration
  def change
    create_table :quickbooks_reference_types do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
