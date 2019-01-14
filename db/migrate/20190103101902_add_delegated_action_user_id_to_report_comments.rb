class AddDelegatedActionUserIdToReportComments < ActiveRecord::Migration[4.2]
  def change
    add_column :report_comments, :delegated_action_user_id, :integer
  end
end
