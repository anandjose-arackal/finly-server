json.unassigned_cards do
  json.array!(@result.unassigned_cards) do |card|
    json.proxy card.proxy
    json.id card.id
  end
end

json.available_card_programs do
  json.array!(CardProgram.all.expense) do |program|
    json.name program.name
    json.card_program_id program.id
  end
end
