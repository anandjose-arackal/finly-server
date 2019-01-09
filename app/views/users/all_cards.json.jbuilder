json.array!(@result.cards) do |card|
  json.serial "#{card.proxy} - #{card.itz_cash_card_program.bank}"
  json.id card.id
end