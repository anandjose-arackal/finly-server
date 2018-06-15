json.array! @result.configs do |config|
  json.id config.company.id
  json.prefix config.prefix
  json.sequence_start config.sequence_start
  json.type config.document_number_config_type.name
end