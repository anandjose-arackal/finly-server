class CreateTransferModes < ActiveRecord::Migration[5.2]
  def change
    create_table :transfer_modes do |t|
      t.integer :company_id
      t.boolean :imps, default: true
      t.boolean :rtgs, default: true
      t.boolean :neft, default: true

      t.timestamps
    end
    add_index :transfer_modes, :company_id
    add_index :transfer_modes, :imps
    add_index :transfer_modes, :rtgs
    add_index :transfer_modes, :neft
  end
end
