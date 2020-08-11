class Masters::Schema::Records::Import::Job < Masters::Schema::Records::Base
  include Transactions::BackgroundWorker
  include Dry::Monads[:result]

  step Model(ImportJob::Master, :find_by)
  step Policy::Pundit(Masters::Schema::Records::Policy, :import?)
  step :init_record_model
  step RecordModelClass()
  step :build_contract
  step :update_properties
  pass :build_headers
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

  def import_data(context, contract:, params:, model:, model_class:, **)
    context[:result] = []
    created_records = 0
    updated_records = 0
    failed_records = 0
    context[:spreadsheet].sheet(0).each(context[:headers]) do |row|
      # Skip headers
      next if (row.values - context[:headers].values).blank?

      data = row.values
      res = import_row(context, contract, model_class, row)
      if res.success?
        case res.value![:action]
        when :create
          created_records += 1
        when :update
          updated_records += 1
        else
          # Invalid action?
        end
      else
        failed_records += 1
      end
      progress_update(model, created_records, updated_records, failed_records)
      data << res.value!['message']
      context[:result] << data
    end
  end

  def progress_update(model, created_records, updated_records, failed_records)
    completed = created_records + updated_records + failed_records
    model.update(
        completed_records: completed,
        created_records: created_records,
        updated_records: updated_records,
        failed_records: failed_records,
        completion_percentage: (completed * 100 / model.total_records)
    )
  end

  def build_result(context, result:, headers:, model:, current_user:, **)
    spreadsheet_builder = Exporter::Spreadsheet.new(current_user, {headers: context[:headers].values, contents: result}, {})

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

  def import_row(context, contract_klass, model_class, row)
    identifier_key = context[:identifier_key]
    record = nil
    action = :update
    if identifier_key.present?
      query = {}
      query[identifier_key]
      record = model_class.find_by(query)
    end

    if record.blank?
      action = :create
      record = model_class.new
    end

    record.assign_attributes(row)
    record.created_by = context[:current_user]
    record.company = context[:current_user].company
    contract = contract_klass.new(record)
    unless contract.validate(row)
      return Failure({message: contract.errors.full_messages.join(',')})
    end

    unless contract.save
      return Failure({message: contract.model.errors.full_messages.join(',')})
    end

    Success({message: 'Saved', action: action})
  end

end