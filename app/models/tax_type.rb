# == Schema Information
#
# Table name: tax_types
#
#  id           :bigint           not null, primary key
#  country_name :string(255)      default("")
#  name         :string(255)      default("")
#  tax_name     :string(255)      default("")
#  deleted_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class TaxType < NonTenantedApplicationRecord
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

  def as_json(options = {})
    {
        id: id,
        name: self.name
    }
  end
end
