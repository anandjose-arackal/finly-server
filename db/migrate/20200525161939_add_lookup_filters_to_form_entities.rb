class AddLookupFiltersToFormEntities < ActiveRecord::Migration[5.2]
  def change
    add_column :form_entities, :filters, :text
  end
end
