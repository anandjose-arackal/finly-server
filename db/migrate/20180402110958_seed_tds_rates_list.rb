class SeedTdsRatesList < ActiveRecord::Migration[4.2]
  def change
    add_column :tds_rates_lists, :company_id, :integer, references: "Company", foreign_key: true, index: true

    Company.all.each do |company|
      TdsRatesList.seed_data(company.id)
    end
  end
end