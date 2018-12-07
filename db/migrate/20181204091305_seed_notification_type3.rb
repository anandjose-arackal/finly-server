class SeedNotificationType3 < ActiveRecord::Migration
  def change
    NotifierType.seed_data
  end
end
