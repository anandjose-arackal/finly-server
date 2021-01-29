class TaxType < ApplicationRecord
  TAXTYPE = [
    {country_name:"india", name: 'IGST', tax_name: 'igst' },
    {country_name:"india", name: 'CGST+SGST', tax_name: 'cgst_sgst' },
    {country_name:"international", name: 'VAT', tax_name: 'vat' },
  ]

  def self.seed_data
    TAXTYPE.each do |tax_type|
      next if TaxType.find_by(tax_name: tax_type[:tax_name].downcase).present?

      TaxType.create(
        country_name: tax_type[:country_name],
        name: tax_type[:name],
        tax_name: tax_type[:tax_name]
      )
    end
  end
end