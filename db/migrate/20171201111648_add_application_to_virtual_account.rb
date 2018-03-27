class AddApplicationToVirtualAccount < ActiveRecord::Migration
  def change
    add_column :virtual_bank_accounts, :application, :string, null: false, index: true
  end
end
