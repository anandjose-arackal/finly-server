json.categories @result.categories
json.card @result.card
json.cash_pockets @result.cash_pockets.each do |pocket|
  @result.details_for(pocket).each do |key, value|
    json.set! key, value
  end
end
json.custom_fields @result.field_configurations