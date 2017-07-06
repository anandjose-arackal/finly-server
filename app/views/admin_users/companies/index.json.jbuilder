json.array!(@result.companies) do |company|
  json.extract! company, :name, :id
  json.created_at company.created_at.to_date.strftime("%d %B %y")
  json.active company.active
  json.ocr_enabled company.ocr_enabled? rescue nil
  json.cards company.itz_cash_property.d_code.present? rescue nil
  json.company_types do
    json.array!(CompanyType.all) do |ct|
      json.id ct.id
      json.name ct.name
    end
  end
end

