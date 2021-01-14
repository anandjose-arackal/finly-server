json.data do
  json.id @op['model'].id
  json.name @op['model'].name
  json.configuration do
    json.legal_entity_name @op['model'].configuration&.legal_entity_name
    json.logo @op['model'].configuration&.logo&.url
    json.start_date @op['model'].configuration&.start_date
    json.end_date @op['model'].configuration&.end_date
  end
  json.created_at @op['model'].created_at
  json.updated_at @op['model'].updated_at
  json.active @op['model'].active
end