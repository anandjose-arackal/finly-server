class SeedVendorConfirmedToStatusTag < ActiveRecord::Migration[5.2]
  def change
  	StatusTag.seed_data
  end
end
