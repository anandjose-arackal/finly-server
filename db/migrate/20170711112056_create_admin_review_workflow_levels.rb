class CreateAdminReviewWorkflowLevels < ActiveRecord::Migration
  def change
    create_table :admin_review_workflow_levels do |t|
      t.references :admin_review_workflow, index: true, foreign_key: true, null: false
      t.integer :position, null: false, index: true
      t.integer :admin_reviewer_id, references: 'AdminUser', index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_reference :card_assign_requests, :admin_review_workflow, index: true, foreign_key: true
    add_column :card_assign_requests, :review_position, :integer, default: 0
    if Company.count > 0
      AdminReviewWorkflow.seed_data
    end
  end
end
