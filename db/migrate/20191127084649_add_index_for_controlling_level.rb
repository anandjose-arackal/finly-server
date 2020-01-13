class AddIndexForControllingLevel < ActiveRecord::Migration[5.2]
  def change
    add_index :bank_payment_requests, :controlling_level_id
    add_index :document_level_reviewer_mappings, :level_number
    add_index :document_level_reviewer_mappings, :taken_control
    add_index :document_level_reviewer_mappings, :forwarded
    add_index :document_level_reviewer_mappings, :viewable
  end
end
