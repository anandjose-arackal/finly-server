class CreateBbpsParentFieldType < ActiveRecord::Migration[6.0]
  def change
    FieldParentType.seed_data
  end
end
