class AddCompanyIdToAgreements < ActiveRecord::Migration
  def change
    add_column :company_agreement_tracks, :company_id, :integer
  end
end
