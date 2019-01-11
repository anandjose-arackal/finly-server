class SeedDataNotifierType < ActiveRecord::Migration[4.2]
  def change
    NotifierType.seed_data
  end
end
