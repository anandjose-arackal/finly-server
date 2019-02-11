class GenerateAutoTransferConfigForCompanies < ActiveRecord::Migration[4.2]
  def change
    companies = Company.all

    companies.each do |company|
      unless company.collect_auto_transfer_config
        company.build_collect_auto_transfer_config.save
      end
    end
  end
end
