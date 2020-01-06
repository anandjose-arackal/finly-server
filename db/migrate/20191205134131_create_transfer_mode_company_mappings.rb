class CreateTransferModeCompanyMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :transfer_mode_company_mappings do |t|
      t.integer :company_id
      t.integer :mode_id, foreign_key: true, references: 'TransferMode'

      t.timestamps
    end

    add_index :transfer_mode_company_mappings, :company_id
    add_index :transfer_mode_company_mappings, :mode_id
  end
end
