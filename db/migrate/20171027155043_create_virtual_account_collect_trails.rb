class CreateVirtualAccountCollectTrails < ActiveRecord::Migration
  def change
    create_table :virtual_account_collect_trails do |t|
      t.boolean :found_virtual_account
      t.boolean :update_company_balance
      t.boolean :create_payment

      t.timestamps null: false
    end
  end
end
