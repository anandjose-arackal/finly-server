json.policies do
  json.array!(@result.policies) do |policy|
    json.id policy.id
    json.name policy.name
  end
end

json.tax_rates do
  json.array! @result.tax_rates do |tax_rate|
    json.merge! tax_rate.as_json
  end
end

json.tds_slabs do
  json.array!(current_company.tds_slabs) do |tds_slab|
    json.id tds_slab.id
    json.name "#{tds_slab.tds}% - #{tds_slab.name} "
    json.tds tds_slab.tds
  end
end

json.payment_agreement_types @result.payment_agreement_types

json.payment_terms do
  json.merge! @result.payment_terms.as_json
end

json.billing_types do
  json.merge! @result.billing_types.as_json
end

json.period do
  json.merge! @result.period.as_json
end