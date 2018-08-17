json.categories @result.categories
json.card @result.card
json.cash_pockets do
  json.array! @result.cash_pockets.each do |pocket|
    json.set! @result.details_for pocket
  end
end
json.custom_fields @result.field_configurations