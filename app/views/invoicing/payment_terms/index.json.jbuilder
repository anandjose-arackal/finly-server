json.array!(@result.payment_terms) do |payment_term|
  json.id payment_term.id
  json.name payment_term.name
  json.days_after payment_term.days_after
  json.description payment_term.description
  json.default payment_term.default
end