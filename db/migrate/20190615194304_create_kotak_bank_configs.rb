class CreateKotakBankConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :kotak_bank_configs do |t|

      t.timestamps
    end
  end
end
