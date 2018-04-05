class SeedDataNotifierType < ActiveRecord::Migration
  def change
    NotifierType.seed_data
  end
end
