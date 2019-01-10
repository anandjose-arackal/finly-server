class AddAddReviewPosToIndividualKycs < ActiveRecord::Migration[4.2]

  def change
    add_column :individual_kycs, :review_position, :integer
    add_reference :individual_kycs, :admin_review_workflow, index: true, foreign_key: true
    add_column :individual_kycs, :upgraded_by_resource_id, :integer, references: 'AdminUser'
    if Company.count > 0
      AdminReviewWorkflow.seed_data
      IndividualKyc.all.update_all(admin_review_workflow_id: AdminReviewWorkflow.workflow_for(:kyc_update).id)
    end
    change_column_null :individual_kycs, :admin_review_workflow_id, false
    add_attachment :individual_kycs, :proof_file_1
    add_column :individual_kycs, :proof_file_1, :string
    add_attachment :individual_kycs, :proof_file_2
    add_column :individual_kycs, :proof_file_2, :string
  end

end
