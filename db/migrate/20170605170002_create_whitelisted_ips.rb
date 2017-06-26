class CreateWhitelistedIps < ActiveRecord::Migration
  def change
    create_table :whitelisted_ips do |t|
      t.string :ip_address, null: false, index: true
      t.references :company, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
