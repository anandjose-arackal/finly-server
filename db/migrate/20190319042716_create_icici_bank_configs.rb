class CreateIciciBankConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :icici_bank_configs do |t|
      t.string :alias
      t.string :urn

      t.timestamps
    end
  end
end
