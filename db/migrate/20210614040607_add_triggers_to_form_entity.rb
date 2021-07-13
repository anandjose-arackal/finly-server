class AddTriggersToFormEntity < ActiveRecord::Migration[6.0]
  def change
    add_column :form_entities, :triggers, :text
  end
end
