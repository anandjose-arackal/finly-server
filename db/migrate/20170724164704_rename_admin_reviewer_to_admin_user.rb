class RenameAdminReviewerToAdminUser < ActiveRecord::Migration
  def change
    # add_column :admin_review_workflow_levels, :admin_user_id, :integer, :references => 'AdminUser', null: false, index: true, foreign_key: true
    AdminReviewWorkflowLevel.all.each do |level|
      level.update(admin_user_id: level.admin_reviewer_id)
    end
    # remove_foreign_key :admin_review_workflow_levels, :admin_reviewer
    remove_index :admin_review_workflow_levels, :admin_reviewer_id
    remove_column :admin_review_workflow_levels, :admin_reviewer_id
  end
end
