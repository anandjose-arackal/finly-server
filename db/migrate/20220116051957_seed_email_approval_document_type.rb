class SeedEmailApprovalDocumentType < ActiveRecord::Migration[6.0]
  def change
    EmailApprovalDocumentType.seed_data
  end
end
