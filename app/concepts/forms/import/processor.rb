class Forms::Import::Processor
  attr_accessor :form, :user, :export_processor, :is_import_submission_stage, :model

  BATCH_SIZE = Rails.application.config_for(:bulk_import)['batch_size'].freeze

  def initialize(form, user)
    self.form = form
    self.user = user
    self.model = form.model
    self.export_processor = Forms::Export::Processor.(form, user)
    self.is_import_submission_stage = false
  end

  def self.call(form, user)
    self.new(form, user)
  end

  def headers
    export_processor.headers
  end

  def lookup_content
    export_processor.lookup_content
  end

  def form_sections
    @form_sections ||= form.sections.includes(entities: { entities: { entities: { entities: :entities } } })
  end

  def build_import_template
    export_base = self.export_processor.build_export_base("#{form.label}_template")

    file = export_base[:file]
    workbook = export_base[:workbook]
    worksheets = export_base[:worksheets]

    self.export_processor.set_lookup_content_in_export(workbook)
    # Deferred for now
    # self.export_processor.add_xlookup_for_ids(workbook)

    workbook.close
    file.rewind

    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 1.day)
    temp_file.file
  end

  def process_meta_data(import_job)
    attachment_keys = {}
    display_keys = {}
    self.headers.each do |key1, value1|
      key1 = 'main' if key1 == form.model.name
      attachment_keys[key1] = []
      display_keys[key1] = []
      value1[:headers].each do |key2, value2|
        if value2[:entity_type] == 'attachment'
          attachment_keys[key1] << value2[:name]
        end

        if value2[:entity]&.display_key
          display_keys[key1] << value2[:name]
        end
      end
    end

    import_job.update(meta_data: {
      attachment_keys: attachment_keys,
      display_keys: display_keys,
    })
  end

  def process_admin_import(request, attachments: nil)
    self.is_import_submission_stage = true

    path = Rails.env.production? ? request.request_file&.url : request.request_file&.path
    imported_sheet = Roo::Spreadsheet.open(path)

    export_base = self.export_processor.build_export_base(form.label)

    file = export_base[:file]
    workbook = export_base[:workbook]
    worksheets = export_base[:worksheets]
    worksheets_length = Hash.new(0)

    worksheets[form.model.name].write(0, self.headers[form.model.name][:headers].keys.count, "Message")

    records_data = build_records_data(imported_sheet)
    records_data.each_with_index do |record_data, row_index|
      begin
        form_data = build_form_data(record_data[:record_data], nil)
        result = process_form_data(form_data, true)
        raise unless result.present?
        Rails.logger.debug "Result::#{result.messages}"
        p "Result::#{result.messages}"
        if result.success?
          message = result.messages[:success].to_s
          request.item_complete(true)
        else
          message = result.messages[:errors].to_s
          request.item_complete(false)
        end
      rescue => exception
        message = "Unable to process"
      end

      add_record_to_result_file(record_data[:record_data], result[:model].id, message, worksheets, worksheets_length)
    end

    workbook.close

    file.rewind

    request.result_file = file
    request.save
    request.progress_update(:completed)
  end

  def preprocess_import_job(import_job)
    path = Rails.env.production? ? import_job.attachment&.url : import_job.attachment&.path
    imported_sheet = Roo::Spreadsheet.open(path)
    raise unless imported_sheet.last_row > 1

    records_data = build_records_data(imported_sheet)
    records_data.each do |record_data|
      record_data.merge!({
        company_id: import_job.company_id,
        import_job_id: import_job.id,
        status_id: ImportRecordStatus.id_for(:pending),
      })
    end

    ImportRecord.insert_all!(records_data)
    import_job.update(status_id: ImportJobStatus.id_for(:pending), total_records: records_data.count)

    records_data
  end

  def build_nested_data(imported_sheet, data_headers)
    nested_data = {}.with_indifferent_access

    imported_sheet.each_with_pagename do |sheet_name, sheet|
      next if sheet_name == form.label
      next unless data_headers[sheet_name].present?

      worksheet_headers = sheet.row(1)

      nested_data[data_headers[sheet_name]] = {}

      (2..sheet.last_row).each do |index|
        row_data = {}.with_indifferent_access
        row = sheet.row(index)
        row.each_with_index do |value, index|
          if sheet.row(1)[index].include? '(Yes/No)'
            value = value == 'Yes' ? 'TRUE' : 'FALSE'
          end
          row_data[worksheet_headers[index]] = value
        end

        row_data['_ref'] = UUIDTools::UUID.timestamp_create().to_s.upcase

        # FE uses this for indexing
        row_data['id'] = row_data['_ref']
        row_data['collection_id'] = row_data['_ref']

        header_details = headers[data_headers[sheet_name]][:headers]

        if row_data[header_details[:parent_id][:name]].present? || row_data[header_details[:parent_sequence_number][:name]].present?
          key = row_data[header_details[:parent_id][:name]]
          key = "Seq#{row_data[header_details[:parent_sequence_number][:name]]}" unless key.present?
          nested_data[data_headers[sheet_name]][key] = [] unless nested_data[data_headers[sheet_name]][key].present?
          nested_data[data_headers[sheet_name]][key] << row_data
        end
      end
    end
    nested_data
  end

  def build_records_data(imported_sheet)
    data_headers = {}
    self.headers.values.each do |sheet_data|
      data_headers[sheet_data[:name]] = sheet_data[:key]
    end

    records_data = []

    nested_data = build_nested_data(imported_sheet, data_headers)

    imported_sheet.each_with_pagename do |sheet_name, sheet|
      worksheet_headers = sheet.row(1)
      if sheet_name == form.label
        worksheet_headers << 'Message'
      end

      # No idea whats happening here
      # worksheet_headers.each_with_index do |header_name, header_index|
      #   worksheet.set_column(header_index, header_index, (header_name&.length.to_i) +10)
      #   worksheet.sheet.write(0, header_index, header_name)
      # end

      if sheet_name == form.label
        (2..sheet.last_row).each do |index|
          row_data = {}.with_indifferent_access
          row = sheet.row(index)
          row.each_with_index do |value, column_index|
            if sheet.row(1)[column_index].include? '(Yes/No)'
              value = value == 'Yes' ? 'TRUE' : 'FALSE'
            end
            row_data[worksheet_headers[column_index]] = value
          end

          row_data['_ref'] = UUIDTools::UUID.timestamp_create().to_s.upcase

          header_details = headers[data_headers[sheet_name]][:headers]

          nested_data.keys.each do |key|
            if row_data[header_details[:id][:name]].present?
              row_data[key] = nested_data[key][row_data[header_details[:id][:name]]].to_s
            elsif row_data[header_details[:import_sequence_number][:name]].present?
              row_data[key] = nested_data[key]["Seq#{row_data[header_details[:import_sequence_number][:name]]}"]
            end
          end

          records_data << {
            uuid: row_data['_ref'],
            record_data: row_data,
            created_at: DateTime.now,
            updated_at: DateTime.now,
          }
        end
      end
    end

    records_data
  end

  def process_import_records(import_job)
    self.is_import_submission_stage = true
    return if import_job.status_id == ImportJobStatus.id_for(:in_progress)

    # updates record count on restarting failed jobs
    import_job.update({
                        failed_records: 0,
                        completed_records: import_job.created_records
                      })

    import_job.progress_update(:in_progress)
    records_to_save = []
    import_job.records.each do |import_record|
      next if import_record.status_id == ImportRecordStatus.id_for(:success)
      next if import_record.status_id == ImportRecordStatus.id_for(:in_progress)

      begin
        import_record.status_id = ImportRecordStatus.id_for(:in_progress)
        import_record.save
        result = process_import_record(import_record)
        raise unless result.present?
        if result.success?
          records_to_save << [result[:model], import_record]
          # import_record.update_status(true, result.messages[:success].to_s, '', '')
          # import_record.document = result[:model]        # import_record.save!      else
          # import_job.item_complete(false)
        else
          import_job.item_complete(false)
          import_record.update_status(false, result.messages[:errors].to_s, '', '')
        end
      rescue => exception
        import_job.item_complete(false)
        import_record.update_status(false, 'Unable to process', exception.message, exception.backtrace)
      end
    end
    save_records(import_job, records_to_save)

    generate_result_file(import_job)
    import_job.progress_update(:completed)
  end

  def save_records(import_job, records_to_save)
    return if records_to_save.empty?

    records_to_save.each do |record, import_record|
      if record.save
        submit_params = { reviewal_document: record }
        op = Docs::P2P::Vendors::Ops::Submit.(params: submit_params, current_user: user)
        if op.success?
          import_record.update_status(true, 'Record created successfully', '', '')
        else
          import_record.update_status(true, 'Record created successfully But could not submit for approval', '', '')
        end
        import_record.document_id = record.id
        import_record.save
        import_job.item_complete(true)
      else
        import_job.item_complete(false)
        import_record.update_status(false, op.messages[:errors].to_s, '', '')
      end
    end
  end

  def generate_result_file(import_job)
    export_base = self.export_processor.build_export_base(form.label)

    file = export_base[:file]
    workbook = export_base[:workbook]
    worksheets = export_base[:worksheets]
    worksheets_length = Hash.new(0)
    worksheets[form.model.name].write(0, self.headers[form.model.name][:headers].keys.count, "Message")

    import_job.records.each do |import_record|
      add_record_to_result_file(import_record.record_data, import_record.document&.id, import_record.message, worksheets, worksheets_length)
    end

    workbook.close
    file.rewind

    import_job.result_file = file
    import_job.save
  end

  def add_record_to_result_file(record_data, document_id, message, worksheets, worksheets_length)
    self.headers.values.each do |sheet_data|
      sheet_name = sheet_data[:name]
      sheet_key = sheet_data[:key]
      if sheet_key == form.model.name
        worksheets_length[sheet_key] += 1
        self.headers[sheet_key][:headers].keys.each_with_index do |key, header_index|
          column_data = record_data[self.headers[sheet_key][:headers][key][:name]]
          if key.to_s == 'id' and document_id.present?
            column_data = document_id
          end

          if column_data.is_a?(Array) && column_data.present? && column_data[0].is_a?(Hash) && column_data[0].has_key?(:url)
            column_data = (column_data.map { |d| d[:url] }).join("\n")
          end
          if self.headers[sheet_key][:headers][key][:name].include? '(Yes/No)'
            column_data = column_data == 'TRUE' ? 'Yes' : 'No'
          end
          worksheets[sheet_key].write(worksheets_length[sheet_key], header_index, column_data)
        end
        worksheets[sheet_key].write(worksheets_length[sheet_key], self.headers[form.model.name][:headers].keys.count, message)
      else
        parent_data = record_data
        record_data[sheet_key]&.each do |child_data|
          worksheets_length[sheet_key] += 1
          self.headers[sheet_key][:headers].keys.each_with_index do |key, header_index|
            column_data = child_data[self.headers[sheet_key][:headers][key][:name]]
            if key.to_s == 'parent_id'
              if document_id.present?
                column_data = document_id
              else
                column_data = parent_data[self.headers[sheet_key][:headers][:id][:name]]
              end
            end
            if column_data.is_a?(Array) && column_data.present? && column_data[0].is_a?(Hash) && column_data[0].has_key?(:url)
              column_data = (column_data.map { |d| d[:url] }).join("\n")
            end
            if self.headers[sheet_key][:headers][key][:name].include? '(Yes/No)'
              column_data = column_data == 'TRUE' ? 'Yes' : 'No'
            end
            worksheets[sheet_key].write(worksheets_length[sheet_key], header_index, column_data)
          end
        end
      end
    end
  end

  def preprocess_import_record(import_record)
    if import_record.processed_data.nil?
      form_data = build_form_data(import_record.record_data, import_record)
    else
      form_data = import_record.processed_data.with_indifferent_access
    end

    form_data
  end

  def process_import_record(import_record)
    form_data = preprocess_import_record(import_record)
    process_form_data(form_data)
  end

  def build_form_data(record_data, import_record)
    form_data = {}.with_indifferent_access

    row_data = record_data.with_indifferent_access

    header_details = headers[form.model.name][:headers]

    existing_record = nil
    if row_data[header_details[:id][:name]].present?
      existing_record = form.model.find(row_data[header_details[:id][:name]])
    end
        
    old_form_data = nil
    if existing_record.present?
      old_form_data = existing_record.form_data(form).with_indifferent_access
    end

    header_details.values.each do |header_data|
      next if header_data[:import_skip]

      if ['attachment'].include?(header_data[:entity_type])
        form_data[header_data[:entity_key]] = get_attachment_entity_value(row_data[header_data[:name]], row_data['_ref'], header_data[:name], header_data[:entity_key], existing_record, import_record)
      elsif ['lookup', 'dropdown'].include?(header_data[:entity_type])
        choice_data = get_entity_value(row_data[header_data[:name]], header_data[:entity], header_data[:entity_type])
        if choice_data.present?
          form_data[header_data[:entity_key]] = choice_data[:id]
          form_data["#{header_data[:entity_key]}_value"] = choice_data[:value]
        end
      else
        form_data[header_data[:entity_key]] = get_entity_value(row_data[header_data[:name]], header_data[:entity], header_data[:entity_type])
      end
    end

    headers[form.model.name][:nested_entities].each do |nested_entity|
      nested_data = row_data.delete(nested_entity.entity_key)
      unless nested_data.present?
        nested_data = []
      end

      form_nested_data = []

      nested_data.each do |nested_row|
        data = {}.with_indifferent_access
        header_details = headers[nested_entity.entity_key][:headers]

        existing_record = nil
        if nested_row[header_details[:id][:name]].present?
          existing_record = headers[nested_entity.entity_key][:entity].populate_if_empty&.find(nested_row[header_details[:id][:name]])
        end

        header_details.values.each do |header_data|
          next if header_data[:import_skip]

          if ['attachment'].include?(header_data[:entity_type])
            data[header_data[:entity_key]] = get_attachment_entity_value(nested_row[header_data[:name]], nested_row['_ref'], header_data[:name], header_data[:entity_key], existing_record, import_record)
          elsif ['lookup', 'dropdown'].include?(header_data[:entity_type])
            choice_data = get_entity_value(nested_row[header_data[:name]], header_data[:entity], header_data[:entity_type])
            if choice_data.present?
              data[header_data[:entity_key]] = choice_data[:id]
              data["#{header_data[:entity_key]}_value"] = choice_data[:value]
            end
          else
            data[header_data[:entity_key]] = get_entity_value(nested_row[header_data[:name]], header_data[:entity], header_data[:entity_type])
          end
        end

        if data[:id].present?
          data[:collection_id] = data[:id]
        else
          data[:id] = UUIDTools::UUID.timestamp_create.to_s.upcase
          data[:collection_id] = data[:id]
        end

        form_nested_data << data
      end

      # if form_data is generated before submission process and existing nested records are missing in excel sheet, add them to form data to show them in Review page of bulk import process
      # if form_data is generated during submission process, we don't need to explicitly add existing records as they will be kept as it is.
      unless self.is_import_submission_stage
        if old_form_data.present? and old_form_data[nested_entity.entity_key].present?
          nested_ids = []
          form_nested_data.each do |n_data|
            next unless n_data[:id].present?
            nested_ids << n_data[:id]
          end

          old_form_data[nested_entity.entity_key].each do |old_n_data|
            next if nested_ids.include?(old_n_data[:id])
            next if nested_ids.include?(old_n_data[:id].to_s)

            form_nested_data << old_n_data
          end
        end
      end

      form_data[nested_entity.entity_key] = form_nested_data
    end

    form_data
  end

  def process_form_data(form_data, is_admin: false)
    Rails.logger.debug "in process form data"
    p 'in process form data'

    form_data[:form] = form
    form_data[:is_import_process] = true

    if form_data[:id].present?
      form_data[:record_query] = { id: form_data[:id] }
    end

    #ToDo: use same operation once batch saving is resolved
    result = if is_admin
               Rails.logger.debug "admin import"
               p 'processing admin import'
               Forms::Import::Ops::AdminCreate.(params: form_data, current_user: user)
             else
               Rails.logger.debug "user import"
               p 'processing import by user'
               Forms::Import::Ops::Create.(params: form_data, current_user: user)
             end

    return result
  end

  def get_entity_value(raw_value, entity, entity_type)
    if ['dropdown'].include?(entity_type)
      get_dropdown_entity_value(raw_value, entity)
    elsif ['lookup'].include?(entity_type)
      get_lookup_entity_value(raw_value, entity)
    elsif ['attachment'].include?(entity_type)
      raise "process attachment using 'get_attachment_entity_value' method"
    else
      parse_value(raw_value, entity)
    end
  end

  def get_dropdown_entity_value(raw_value, entity)
    return unless raw_value

    choice = entity.choices_scope.find_by_id(raw_value, user: user)
    return unless choice.present?

    if choice.respond_to?(:dig)
      choice_id = choice&.dig(:id)
      choice_value = choice&.dig(:name)
    else
      choice_id = choice&.id
      choice_value = choice&.name
    end

    {
      id: parse_value(choice_id, entity),
      value: choice_value,
    }.with_indifferent_access
  end

  def get_lookup_entity_value(raw_value, entity)
    return unless raw_value

    choice = entity.choices_scope.find_by_id(raw_value, user: user)
    return unless choice.present?

    choice_name = nil
    if choice.respond_to?(:name)
      choice_value = choice.name
    elsif choice.respond_to?(:display_name)
      choice_value = choice.display_name
    end

    {
      id: parse_value(choice.id, entity),
      value: choice_value,
    }.with_indifferent_access
  end

  def get_attachment_entity_value(raw_value, reference_id, header_name, entity_key, existing_record, import_record)
    atts_json = []

    if existing_record.present?
      field = existing_record.form_custom_fields.joins(:form_entity).where("form_entities.entity_key = ?", entity_key).first
      atts_json = field.attachments.as_json if field.present?
    end

    return atts_json unless import_record.present?

    atts = import_record.import_job.import_job_attachments.where(identifier: "#{reference_id}_#{header_name}")

    if raw_value.present?
      atts = atts.or(import_record.import_job.import_job_attachments.where(identifier: raw_value.split("\n")))
    end

    atts.each do |att|
      attachment = CustomFieldAttachment.new
      attachment.attachment = att.attachment
      attachment.save
      
      atts_json << attachment.as_json
    end

    atts_json
  end

  def parse_value(value, entity)
    return value.to_s.strip unless entity.present?
    return entity.default_value unless value.present?

    case value
    when Float, Integer
      if ['number', 'amount'].include?(entity.entity_type)
        value
      else
        value.to_i.to_s.strip
      end
    when ::Date
      value.strftime('%Y-%m-%d')
    when ::DateTime
      value.strftime('%Y-%m-%d %H:%M:%S')
    else
      value.to_s.strip
    end
  end
end
