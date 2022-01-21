class DropEmailApprovalStatus < ActiveRecord::Migration[6.0]
  def change
    drop_table :email_approval_statuses
  end
end
