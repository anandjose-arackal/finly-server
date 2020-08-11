class Masters::Schema::Records::Import::Contract < Reform::Form

  property :name, validates: {presence: true}
  property :request_params, deserializer: -> (input, represented, **) {represented.request_params = input}
  property :options, deserializer: -> (input, represented, **) {represented.options = {master_schema: input[:master_key]}}
  property :status_id, deserializer: -> (input, represented, **) {represented.status_id = ImportJobStatus.id_for(:pending)}
  property :attachment, validates: {presence: true}

end