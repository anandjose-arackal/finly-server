class AddShowInDataCardAsToFormEntities < ActiveRecord::Migration[6.0]
  def change
    add_column :form_entities, :data_card_config, :text
  end
end
