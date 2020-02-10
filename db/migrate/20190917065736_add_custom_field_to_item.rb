class AddCustomFieldToItem < ActiveRecord::Migration[5.2]
  def change
    FieldParentType.seed_data
  end
end
