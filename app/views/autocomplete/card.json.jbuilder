json.array!(@result.cards) do |card|
  json.proxy card.proxy
  json.id card.id
end