class CreateYesBankConfigurations < ActiveRecord::Migration[4.2]
  def change
    create_table :yes_bank_configurations do |t|
      t.boolean :custom_bank_account, default: false
      t.references :company
      t.boolean :yes_bank_api_enabled, default: false

      t.timestamps null: false
    end
  end
end
