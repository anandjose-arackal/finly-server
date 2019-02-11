class ChangeTaxToTaxRateIdForAll < ActiveRecord::Migration[4.2]
  def change
    # Moving taxes in model
    # taxes = [0, 0.1, 0.25, 3, 5, 12, 18, 28]
    #
    # companies = Company.all
    #
    # companies.each do |company|
    #   #Create default taxes for all companies
    #   taxes.each do |tax|
    #     company.tax_rates.create(name: tax.to_s, rate: tax)
    #   end
    #
    #
    #   # Find inventory items and tax_rate id for tax
    #   company.inventory_line_items.each do |item|
    #     tax = item.tax
    #
    #     if tax.present?
    #       tax_rate_id = company.tax_rates.with_rate(tax).first&.id
    #     else
    #       tax_rate_id = company.tax_rates.with_rate(0).first&.id
    #     end
    #
    #     item.update(tax_rate_id: tax_rate_id)
    #   end
    # end
  end
end
