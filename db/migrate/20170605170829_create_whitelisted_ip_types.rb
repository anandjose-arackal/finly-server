class CreateWhitelistedIpTypes < ActiveRecord::Migration
  def change
    create_table :whitelisted_ip_types do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    add_column :whitelisted_ips, :whitelisted_ip_type_id, :integer, references: 'WhitelistedIpType', null: false, index: true, foreign_key: true
    if Company.count > 0
      WhitelistedIpType.seed_data
    end
  end
end
