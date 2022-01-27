class RemoveEmailApprovalStatusId < ActiveRecord::Migration[6.0]
  def change
    remove_column :email_approvals, :email_approval_status_id, :integer
  end
end
