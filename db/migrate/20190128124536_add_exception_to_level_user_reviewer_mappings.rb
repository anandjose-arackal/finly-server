class AddExceptionToLevelUserReviewerMappings < ActiveRecord::Migration[5.2]
  def change
    add_column :level_user_reviewer_mappings, :exception, :boolean, default: false
  end
end
