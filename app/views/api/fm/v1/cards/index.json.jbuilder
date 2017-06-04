json.array! @result.paginated_cards do |card|
  json.partial! 'card', card: card
end