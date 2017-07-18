class AddCompanyIdToIndividualKyc < ActiveRecord::Migration
  def change
    # add_reference :individual_kycs, :company, index: true, foreign_key: true
    IndividualKyc.all.each do |kyc|
      kyc.update(company_id: kyc.user.company_id)
    end
    change_column_null :individual_kycs, :company_id, false
  end
end
