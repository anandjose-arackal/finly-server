task :add_form_currencies_to_companies => :environment do
  Company.all.pluck(:id).each do |company_id|
    next if  FormCurrency.find_by(company_id: company_id).present?
    currencies_with_company = []
    FormEntity::Currency::CURRENCIES.each do |currency_hash|
      currency_hash = {:currency=> nil, :currency_code=> nil, :symbol=> nil, :company_id=> nil}.merge(currency_hash)
      currencies_with_company.push(currency_hash.merge({company_id: company_id}))
    end
    FormCurrency.import currencies_with_company, validate: false
  end
end
