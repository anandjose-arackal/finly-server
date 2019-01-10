class SeedFieldParentTypes < ActiveRecord::Migration[4.2]
  def change
    FieldParentType.seed_data
  end
end
