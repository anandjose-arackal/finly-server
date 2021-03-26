class AddComputeLookupAssigmentsToFormEntities < ActiveRecord::Migration[6.0]
  def change
    add_column :form_entities, :compute_lookup_assignments, :text
  end
end
