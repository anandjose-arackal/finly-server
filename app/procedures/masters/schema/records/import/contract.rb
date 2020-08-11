class Masters::Schema::Records::Import::Contract < Reform::Form

  property :name, validates: {presence: true}
  property :request_params, deserializer: -> (input, represented, **) {represented.request_params = input}
  property :options, deserializer: -> (input, represented, **) {
    represented.options = {
        master_schema: input[:master_key],
        mode: input[:mode]
    }
  }
  property :status_id, deserializer: -> (input, represented, **) {represented.status_id = ImportJobStatus.id_for(:pending)}
  property :attachment, validates: {presence: true}

  validate :validate_options

  def validate_options
    if options[:master_schema].blank?
      errors.add :base, 'master not found'
      return
    end

    unless ImportJob::Master::MODES.include?(options[:mode])
      errors.add :base, 'invalid mode'
    end
  end

end