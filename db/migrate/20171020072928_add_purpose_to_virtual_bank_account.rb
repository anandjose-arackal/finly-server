class AddPurposeToVirtualBankAccount < ActiveRecord::Migration
  def change
    add_column :virtual_bank_accounts, :purpose_id, :integer, references: "VirtualAccountPurpose", foreign_key: true, index: true
  end
end
