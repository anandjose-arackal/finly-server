json.array!(@result.cards) do |card|
  json.label card.proxy
  json.value card.id
end