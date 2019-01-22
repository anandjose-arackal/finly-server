class AddTriggerEmailToAdminReviewWorkflowLevels < ActiveRecord::Migration[4.2]
  def change
    add_column :admin_review_workflow_levels, :trigger_email, :boolean, default: false, null: false
    add_column :admin_review_workflow_levels, :reviewer, :boolean, default: false, null: false
  end
end
