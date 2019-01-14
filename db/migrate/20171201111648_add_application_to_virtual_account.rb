class AddApplicationToVirtualAccount < ActiveRecord::Migration[4.2]
  def change
    add_column :virtual_bank_accounts, :application, :string, null: false, index: true
  end
end
