class AddSectionIdToFormSections < ActiveRecord::Migration[5.2]
  def change
    rename_column :form_sections, :name, :section_id
    add_column :form_sections, :title, :string
  end
end
