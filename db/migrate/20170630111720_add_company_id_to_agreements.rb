class AddCompanyIdToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :company_agreement_tracks, :company_id, :integer
  end
end
