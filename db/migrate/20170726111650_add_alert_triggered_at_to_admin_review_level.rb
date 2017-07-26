class AddAlertTriggeredAtToAdminReviewLevel < ActiveRecord::Migration
  def change
    add_column :admin_review_workflow_levels, :email_triggered_at, :datetime
  end
end
