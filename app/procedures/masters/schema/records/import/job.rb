class Masters::Schema::Records::Import::Job < Masters::Schema::Records::Base
  include Transactions::BackgroundWorker
  include Dry::Monads[:result]

  step Model(ImportJob::Master, :find_by_uuid)
  step Policy::Pundit(Masters::Schema::Records::Policy, :import?)
  step :init_record_model
  step RecordModelClass()
  step :build_contract
  step :update_properties
  pass :build_headers
  pass :build_input
  pass :cache_lookup_associations
  pass :import_data
  pass :build_result

  def init_record_model(context, params:, model:, current_user:, **)
    params[:master_key] = model.options['master_key']
  end

  def build_contract(context, master_schema:, model_class:, **)
    context[:contract] = master_schema.contract
  end

  def update_properties(context, model:, **)
    context[:spreadsheet] = ImportUtil.open_spreadsheet(model.attachment)
    model.update(
        total_records: (context[:spreadsheet].last_row - 1),
        completed_records: 0,
        completion_percentage: 0,
        created_records: 0,
        updated_records: 0,
        failed_records: 0
    )
  end

  def build_headers(context, params:, master_schema:, **)
    context[:headers] = {}.with_indifferent_access
    context[:identifier_key] = master_schema.sequence_entity&.entity_key
    master_schema.entities.each do |entity|
      context[:headers][entity.entity_key] = entity.label
    end
  end

  def build_input(context, params:, master_schema:, **)
    context[:input] = []

    context[:spreadsheet].sheet(0).each(context[:headers]) do |row|
      next if (row.values - context[:headers].values).blank?

      context[:input] << row
    end

    true
  end

  # Lookup cache is used for bulk fetching all the associations for lookup entities
  # key is always the referring entity
  # value is an hash having inputs as keys and the association ID as the value
  def cache_lookup_associations(context, input:, master_schema:, **)
    context[:lookup_cache] = lookup_cache = {}
    context[:input].each do |row|
      master_schema.entities.each do |entity|
        next unless entity.type?(:lookup)

        lookup_cache[entity] ||= {}
        lookup_cache[entity][row[entity.entity_key]] = nil
      end
    end

    lookup_cache.each do |entity, inputs|
      entity.lookup_master_schema.record_model_class.where(company_id: entity.company_id, entity.lookup_master_schema.primary_entity_key => inputs.keys).each { |record|
        inputs[record.send(entity.lookup_master_schema.primary_entity_key)] = record.id
      }
    end
  end

  def import_data(context, contract:, master_schema:, lookup_cache:, params:, model:, model_class:, **)
    context[:result] = []
    created_records = 0
    updated_records = 0
    failed_records = 0
    skipped_records = 0
    context[:input].each do |row|
      data = row.values
      lookup_errors = []
      if lookup_cache.present?
        lookup_cache.each do |entity, inputs|
          value = row[entity.entity_key]
          next if value.blank?

          if inputs[value].blank?
            lookup_errors << "#{value} not found for #{entity.label}"
          else
            row[entity.entity_key] = inputs[value]
          end
        end
      end

      import_result = nil
      import_result = Failure(lookup_errors.join(", ")) if lookup_errors.present?

      import_result ||= import_row(context, master_schema, contract, model_class, row)
      if import_result.success?
        data << 'Success'
        case import_result.success[:action]
        when :create
          created_records += 1
        when :update
          updated_records += 1
        when :skip
          skipped_records += 1
        else
          # Invalid action?
        end
      else
        failed_records += 1
        data << 'Failed'
        data << import_result.failure
      end
      progress_update(model, created_records, updated_records, skipped_records, failed_records)
      context[:result] << data
    end
  end

  def progress_update(model, created_records, updated_records, skipped_records, failed_records)
    completed = created_records + updated_records + skipped_records + failed_records
    model.update(
        completed_records: completed,
        created_records: created_records,
        updated_records: updated_records,
        skipped_records: skipped_records,
        failed_records: failed_records,
        completion_percentage: (completed * 100 / model.total_records)
    )
  end

  def build_result(context, result:, model:, current_user:, **)
    headers = context[:headers].values
    headers << 'Status'
    headers << 'Message'
    spreadsheet_builder = Exporter::Spreadsheet.new(current_user, {headers: headers, contents: result}, {})

    if model.attachment_file_name.end_with?(".csv")
      # CSV
      file = spreadsheet_builder.generate_csv_file
    else
      # Excel
      file = spreadsheet_builder.generate_xls_file
    end
    context[:'result.file'] = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 1.day)
  end

  protected

  def import_row(context, master_schema, contract_klass, model_class, row)
    record = find_record(context, row[identifier_key(context)])
    action = :update

    if record.blank?
      action = :create
      record = model_class.new
    elsif record.present? and context[:model].options['mode'] != 'create_update'
      # Skip record
      return Success(message: "Skipped", action: :skip)
    end

    record.created_by = context[:current_user]
    record.company = context[:current_user].company

    if row['parent_id'].present?
      row['parent_id'] = find_record(context, row['parent_id'])&.id
    end

    contract = contract_klass.new(record)
    unless contract.validate(row)
      return Failure(contract.errors.full_messages.join(','))
    end

    unless contract.save
      return Failure(contract.model.errors.full_messages.join(','))
    end

    Success({action: action})
  end

  # Finds the record using the unique identifier
  def find_record(context, id)
    return nil if id.blank?
    return nil unless identifier_key(context).present?

    # query = {}
    # query[identifier_key(context)] = id
    context[:model_class].find_by(identifier_key(context) => id)
  end

  def identifier_key(context)
    context[:identifier_key]
  end

end