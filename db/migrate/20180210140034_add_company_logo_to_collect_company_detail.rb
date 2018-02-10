class AddCompanyLogoToCollectCompanyDetail < ActiveRecord::Migration
  def change
    add_attachment :collect_company_details, :company_logo
  end
end
