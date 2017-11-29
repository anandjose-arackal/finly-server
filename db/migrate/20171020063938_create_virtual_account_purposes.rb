class CreateVirtualAccountPurposes < ActiveRecord::Migration
  def change
    create_table :virtual_account_purposes do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
