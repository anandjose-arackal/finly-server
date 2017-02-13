json.array! @result.items.each do |item|
  json.name item[:name]
  json.total item[:total]
  json.via_card item[:via_card]
  json.via_cash item[:via_cash]
end