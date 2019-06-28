class CreateBankAccountProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :bank_account_providers do |t|
      t.string :name

      t.timestamps
    end
  end
end
