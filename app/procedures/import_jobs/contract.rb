class ImportJobs::Contract < Reform::Form

  property :created_by_id
  property :company_id, validates: { presence: true }
  property :name, deserializer: -> (input, represented, **) {
    represented.name = input[:route]
  }
  property :request_params, deserializer: -> (input, represented, **) {represented.request_params = input}
  property :options, deserializer: -> (input, represented, **) {
    represented.options = {
        route: input[:route],
        mode: 'create_update'
    }
  }
  property :status_id, deserializer: -> (input, represented, **) {represented.status_id = ImportJobStatus.id_for(:preprocessing)}
  property :attachment, validates: {presence: true}

  property :require_attachments, deserializer: -> (input, represented, **) {
    represented.require_attachments = true
  }

  validate :validate_options

  def validate_options
    if options[:route].blank?
      errors.add :base, 'route not found'
      return
    end

    unless ImportJob::MODES.include?(options[:mode])
      errors.add :base, 'invalid mode'
    end
  end

end