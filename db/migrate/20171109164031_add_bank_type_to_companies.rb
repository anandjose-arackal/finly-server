class AddBankTypeToCompanies < ActiveRecord::Migration[4.2]
  def change
    add_column :company_configurations, :bank_type, :string

    # setting the bank type retrospectively for all companies
    hdfc = [4, 12, 18, 38]
    Company.all.each do |company|
      if hdfc.include?(company.id)
        company.configuration.update(bank_type: "HDFC")
      else
        company.configuration.update(bank_type: "RBL")
      end
    end
  end
end
