json.array!(@result.cards) do |card|
  json.serial card.proxy
  json.id card.id
end