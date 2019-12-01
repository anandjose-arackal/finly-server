class RemoveParentFromFormEntity < ActiveRecord::Migration[5.2]
  def change
    remove_column :form_entities, :parent_id
    add_column :form_sections, :section_type, :string
  end
end
