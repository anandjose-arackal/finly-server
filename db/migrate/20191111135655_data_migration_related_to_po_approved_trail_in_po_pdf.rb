class DataMigrationRelatedToPoApprovedTrailInPoPdf < ActiveRecord::Migration[5.2]
  def change
     company_ids = [137,156,166,179,173,209]
     CompanyConfiguration.where.not(company_id: company_ids).update_all(show_po_approved_trail: true)
  end
end
