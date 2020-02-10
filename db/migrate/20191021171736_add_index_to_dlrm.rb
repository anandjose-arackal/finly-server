class AddIndexToDlrm < ActiveRecord::Migration[5.2]
  def change
    add_index :document_level_reviewer_mappings, [:document_reviewer_mappable_type, :provider_name, :policy_id ], :name => "index_dlrm_provider_policy_mappable_type"
  end
end
