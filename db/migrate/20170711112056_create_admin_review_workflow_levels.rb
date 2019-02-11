class CreateAdminReviewWorkflowLevels < ActiveRecord::Migration[4.2]
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
      # creating admin panel users who can access admin panel
      AdminUser.create!(email: 'sreeram.nr@finly.io', password: 'demo1234', password_confirmation: 'demo1234', mobile_number: '9986676711',
                        admin_user_role_mappings_attributes: [{admin_user_role_id: AdminUserRole.id_for(:admin)}, {admin_user_role_id: AdminUserRole.id_for(:transcriber)}])
      AdminUser.create!(email: 'vivek.a@finly.io', password: 'demo1234', password_confirmation: 'demo1234', mobile_number: '9986676713',
                        admin_user_role_mappings_attributes: [{admin_user_role_id: AdminUserRole.id_for(:itzcash_verifier)}])
      AdminUser.create!(email: 'veekshith.rai@finly.io', password: 'demo1234', password_confirmation: 'demo1234', mobile_number: '9886321387',
                        admin_user_role_mappings_attributes: [{admin_user_role_id: AdminUserRole.id_for(:itzcash_operations)}])
      AdminReviewWorkflow.seed_data
    end
  end
end
