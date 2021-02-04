class SeedTaxRateData < ActiveRecord::Migration[6.0]
  def change

    TaxRate.non_deleted.all.each do |tax_rate| 

      tax_rate.update(name: 'CGST + SGST')

      TaxRate.create(
        name: 'IGST',
        company_id: tax_rate.company_id,
        rate: tax_rate.rate
      )
    end
  end
end
