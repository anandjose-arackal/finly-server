class AddVirtualToFormEntity < ActiveRecord::Migration[6.0]
  def change
    add_column :form_entities, :virtual, :boolean, default: false
  end
end
