class SeedFieldParentTypeBookingRequest < ActiveRecord::Migration
  def change
    FieldParentType.seed_data
  end
end
