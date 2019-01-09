class SeedFieldParentType < ActiveRecord::Migration
  def change
    FieldParentType.seed_data
  end
end
