class MakeReviewalChainSoftDeletable < ActiveRecord::Migration
  def change
    add_column :reviewal_levels, :is_deleted, :boolean, default: false, null: false
    add_column :level_reviewer_mappings, :is_deleted, :boolean, default: false, null: false
    add_column :policy_user_mappings, :is_deleted, :boolean, default: false, null: false
  end
end
