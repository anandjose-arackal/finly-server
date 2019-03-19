class CreateIciciBankConfigForAllCompanies < ActiveRecord::Migration[5.2]
  def change
    Company.all.each do |company|
      company.build_icici_bank_config.save
    end
  end
end
