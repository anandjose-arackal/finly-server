class Forms::Import::Processor
  attr_accessor :form, :user, :export_processor, :is_import_submission_stage, :model, :value_id_map

  BATCH_SIZE = Rails.application.config_for(:bulk_import)['batch_size'].freeze

  def initialize(form, user)
    self.form = form
    self.user = user
    self.model = form.model
    self.export_processor = Forms::Export::Processor.(form, user)
    self.is_import_submission_stage = false
    self.value_id_map = export_processor.lookup_content.map{|data| [data[:name], data[:data][:choices].map{ |choice| [choice[:name], choice[:id]]}.to_h]}.to_h
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
  #
  # def lookup_labels
  #   @lookup_labels || lookup_content.pluck(:name)
  # end

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
        if result.success?
          message = result.messages[:success].to_s
          request.item_complete(true)
        else
          message = result.messages[:errors].to_s
          request.item_complete(false)
        end

        add_record_to_result_file(record_data[:record_data], {}, result[:model].id, message, worksheets, worksheets_length)
      rescue => exception
        message = "Unable to process, #{exception}"
        request.item_complete(false)
        add_record_to_result_file(record_data[:record_data],{}, nil, message, worksheets, worksheets_length)
      end
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
          next if sheet.row(1)[index].nil?
          if sheet.row(1)[index].include? '(Yes/No)'
            value = value == 'Yes' ? 'TRUE' : 'FALSE'
          end
          # if lookup_labels.include? sheet.row(1)[index].gsub('*', '')
          #   row_data["#{worksheet_headers[index].gsub('*', '')} ID"] = get_id_from_value(value, sheet.row(1)[index])
          # end
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
            next if sheet.row(1)[column_index].nil?
            if sheet.row(1)[column_index].include? '(Yes/No)'
              value = value == 'Yes' ? 'TRUE' : 'FALSE'
            end

            # if lookup_labels.include? sheet.row(1)[column_index].gsub('*', '')
            #   row_data["#{worksheet_headers[column_index].gsub('*', '')} ID"] = get_id_from_value(value, sheet.row(1)[column_index])
            # end
            row_data[worksheet_headers[column_index]] = value
          end

          row_data['_ref'] = UUIDTools::UUID.timestamp_create().to_s.upcase

          header_details = headers[data_headers[sheet_name]][:headers]
          nested_data.keys.each do |key|
            if row_data[header_details[:id][:name]].present?
              row_data[key] = (nested_data[key][row_data[header_details[:id][:name]]] || nested_data[key][row_data["seq#{header_details[:import_sequence_number][:name]}"]])
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
        RequestStoreUtil.set_current_user(user)
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
        import_record.update_status(false, ["Unable to process, #{exception.message}"].to_s, exception.message, exception.backtrace)
      end
    end
    save_records(import_job, records_to_save)

    generate_result_file(import_job)
    import_job.progress_update(:completed)
  end

  def save_records(import_job, records_to_save)
    return if records_to_save.empty?

    records_to_save.each do |record, import_record|
      if [Invoice, PurchaseOrder].include? form.model
        record.items&.each do |item|
          item.id = nil
        end
        record.import_job_id = import_job.id
        if form.model == PurchaseOrder
          record.purchase_order_status_id = PurchaseOrderStatus.id_for(:open)
          record.form_migrated = true
          record.quotations.each do |quote|
            quote.id = nil
          end
        end
      end
      if record.save
        policy = record.policy
        if record.class == YesBankVendor
          submit_params = { reviewal_document: record }
          op = Docs::P2P::Vendors::Ops::Submit.(params: submit_params, current_user: user)
        elsif record.class == Invoice
          document_reviewer_mappings = policy.levels.non_deleted.with_entity_type('NonPoInvoiceProvider').reorder(:level_number).map{|x| {level_id: x.id}} rescue nil
          submit_params = {
            reviewal_document: record,
            policy_id: record.policy_id,
            document_reviewer_mappings: document_reviewer_mappings
          }
          op = Docs::I2P::Invoices::Ops::Submit.(params: submit_params, current_user: user)
        elsif record.class == PurchaseOrder
          document_reviewer_mappings = policy.levels.non_deleted.with_entity_type('PurchaseOrderProvider').reorder(:level_number).map{|x| {level_id: x.id}} rescue nil
          master = 'Docs::P2P::PurchaseOrders::Form'
          po_form = Form.where(klass_name: master).first
          sequence_entity = po_form.entities.where(entity_key: 'po_number').first
          if sequence_entity.present?
            prefix, sequence = FormEntity::AutoNumber.fetch_autonumber(sequence_entity, self)
            po_number = prefix + sequence
            record.update(po_number: po_number)
          end
          submit_params = {
            reviewal_document: record,
            policy_id: record.policy_id,
            document_reviewer_mappings: document_reviewer_mappings
          }
          op = Docs::I2P::PurchaseOrders::Ops::Submit.(params: submit_params, current_user: user)
        end
        if op&.success?
          import_record.update_status(true, ['Record created successfully'].to_s, '', '')
        else
          import_record.update_status(true, ['Record created successfully But could not submit for approval', op.messages[:errors].join(', ')].to_s, '', '')
        end
        import_record.document_id = record.id
        import_record.save
        import_job.item_complete(true)
      else
        import_job.item_complete(false)
        import_record.update_status(false, record.errors.messages.values.flatten.to_s, '', '')
      end
    end
  end

  def generate_result_file(import_job)
    export_base = self.export_processor.build_export_base(form.label)

    file = export_base[:file]
    workbook = export_base[:workbook]
    worksheets = export_base[:worksheets]
    worksheets_length = Hash.new(0)

    import_job.records.each do |import_record|
      add_record_to_result_file(import_record.record_data, import_record.processed_data, import_record.document&.id, import_record.message, worksheets, worksheets_length)
    end

    workbook.close
    file.rewind

    import_job.result_file = file
    import_job.save
  end

  def add_record_to_result_file(record_data, processed_data, document_id, message, worksheets, worksheets_length)
    self.headers.values.each do |sheet_data|
      sheet_name = sheet_data[:name]
      sheet_key = sheet_data[:key]
      if sheet_key == form.model.name
        skipped_count = 0
        worksheets_length[sheet_key] += 1
        self.headers[sheet_key][:headers].keys.each_with_index do |key, header_index|
          if self.headers[sheet_key][:headers][key]["hide_in_sheet"]
            skipped_count += 1
            next
          end
          data = processed_data[self.headers[sheet_key][:headers][key][:entity_key].gsub('_id', '_id_value')] rescue nil
          column_data = data || record_data[self.headers[sheet_key][:headers][key][:name]]
          if key.to_s == 'id' and document_id.present?
            column_data = document_id
          end

          if column_data.is_a?(Array) && column_data.present? && column_data[0].is_a?(Hash) && column_data[0].has_key?(:url)
            column_data = (column_data.map { |d| d[:url] }).join("\n")
          end
          if self.headers[sheet_key][:headers][key][:name].include? '(Yes/No)'
            column_data = column_data == 'TRUE' ? 'Yes' : 'No'
          end
          worksheets[sheet_key].write(worksheets_length[sheet_key], header_index - skipped_count, column_data)
        end
        worksheets[form.model.name].write(0, self.headers[form.model.name][:headers].keys.count - skipped_count, "Message")
        worksheets[sheet_key].write(worksheets_length[sheet_key], self.headers[form.model.name][:headers].keys.count - skipped_count, message)
      else
        skipped_count = 0
        parent_data = record_data
        record_data[sheet_key]&.each_with_index do |child_data, child_index|
          processed_child_data = sheet_key == "items_summary" ? processed_data : processed_data[sheet_key][child_index] rescue nil
          worksheets_length[sheet_key] += 1
          self.headers[sheet_key][:headers].keys.each_with_index do |key, header_index|
            if self.headers[sheet_key][:headers][key]["hide_in_sheet"]
              skipped_count += 1
              next
            end
            data = processed_child_data[self.headers[sheet_key][:headers][key][:entity_key].gsub('_id', '_id_value')] rescue nil
            column_data = data || child_data[self.headers[sheet_key][:headers][key][:name]]
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
            column_data = %w[account_number confirm_account_number].include?(self.headers[sheet_key][:headers][key][:entity_key]) ? "\t" + column_data.to_s : column_data
            worksheets[sheet_key].write(worksheets_length[sheet_key], header_index - skipped_count, column_data)
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
        choice_id = row_data[header_data[:name]].nil? ? nil : get_id_from_value(row_data[header_data[:name]], header_data[:name])
        if choice_id.present?
          form_data[header_data[:entity_key]] = choice_id
          form_data["#{header_data[:entity_key]}_value"] = row_data[header_data[:name]]
        else
          choice_data = get_entity_value(row_data[header_data[:name]], header_data[:entity], header_data[:entity_type])
          if choice_data.present?
            form_data[header_data[:entity_key]] = choice_data[:id]
            form_data["#{header_data[:entity_key]}_value"] = choice_data[:value]
          end
        end

        if header_data[:entity_key] == 'vendor_id'
          form.entities.where(entity_key: ['receiving_account_id', 'gstin_location_id']).each do |field|
            filter = field.entity_key == 'gstin_location_id' ? { vendor_id_in: [form_data['vendor_id']]} : {account_owner_id_in: [form_data['vendor_id']] }
            value_id_map.delete(field.label)
            value_id_map[field.label] = form.entities.where(entity_key: field.entity_key).first.choices_scope.build(user: self.user, params: { paginate: false, q: filter }).as_json[:choices].map{ |x| [x[:name], x[:id]] }.to_h
          end
        end
        
        # running lookup fetch on all lookups
        if header_data[:entity_type] == 'lookup' && form_data[header_data[:entity_key]].present? #header_data[:entity].has_dependents
          params_hash = {:entity_path => header_data[:entity].entity_path, :route => "#{form.label.underscore.to_s}_import", :value => form_data[header_data[:entity_key]]}
          current_user = user
          lookup_data = Forms::Ops::LookupDetails.(params: params_hash, current_user: current_user)[:data] rescue nil
          form_data = lookup_data.merge(form_data) if lookup_data.present?
        end
      else
        if row_data[header_data[:name]].present?
          form_data[header_data[:entity_key]] = get_entity_value(row_data[header_data[:name]], header_data[:entity], header_data[:entity_type])
        end
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
            choice_id = nested_row[header_data[:name]].nil? ? nil : get_id_from_value(nested_row[header_data[:name]], header_data[:name])
            if choice_id.present?
              data[header_data[:entity_key]] = choice_id
              data["#{header_data[:entity_key]}_value"] = nested_row[header_data[:name]]
            else
              choice_data = get_entity_value(nested_row[header_data[:name]], header_data[:entity], header_data[:entity_type])
              if choice_data.present?
                data[header_data[:entity_key]] = choice_data[:id]
                data["#{header_data[:entity_key]}_value"] = choice_data[:value]
              end
            end

            # running lookup fetch on all lookups
            if header_data[:entity_type] == 'lookup' && header_data[:entity].choices_scope.present? && data[header_data[:entity_key]].present? #header_data[:entity].has_dependents
              params_hash = {:entity_path => header_data[:entity].entity_path, :route => form.label.underscore.to_s, :value => data[header_data[:entity_key]]}
              current_user = user
              lookup_data = Forms::Ops::LookupDetails.(params: params_hash, current_user: current_user)[:data].map{|k, v| [k.split('.').last, v]}.to_h rescue {}

              # Tax percentage should be 0 if not provided in sheet, removing from lookup data
              lookup_data = lookup_data.except('tax_percentage', 'tax_rate_id', 'tax_rate_id_value') if header_data[:entity_key] != 'tax_rate_id'
              
              data = data.merge(lookup_data)
            end
          else
            # Set value from sheet if lookup returned 0 or nil but sheet has data
            if nested_row[header_data[:name]].present?
              data[header_data[:entity_key]] = get_entity_value(nested_row[header_data[:name]], header_data[:entity], header_data[:entity_type])
            end
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
      if nested_entity.entity_key == 'items_summary'
        form_data.merge!(form_nested_data[0]) if form_nested_data[0]
      else
        form_data[nested_entity.entity_key] = form_nested_data
      end
    end

    form_data = perform_form_calculations(form_data) if [Invoice, PurchaseOrder].include? form.model

    dropdowns = headers[form.model.name][:headers].values.select{|header_value| header_value['entity_type'] == 'dropdown'}
    dropdowns.each do |header_data|
      choices = header_data[:entity].choices_scope.build.data
      form_data["#{header_data[:entity_key]}_value"] = choices.select{|x| x['id'].to_i == form_data[header_data[:entity_key]].to_i}.first['name'] rescue nil
    end

    form_data
  end

  # Specific use case for invoices and PO items
  def perform_form_calculations(form_data)
    form.entities.each do |entity|
      if entity.class.collection?
        collection_data = form_data[entity.entity_key.to_s] || []
        next if collection_data.empty?
        child_results = []
        collection_data.each do |item|
          result = {}
          entity.entities.each do |child_entity|
            next unless child_entity.compute_enabled && child_entity.compute_type_id == 1
            result[child_entity.entity_key] = LiquidHelper.interpolate(child_entity.compute_formula, {'form'=>form_data, 'row'=>item})
            item[child_entity.entity_key] = result[child_entity.entity_key]
          end
          child_results << item
        end
        form_data[entity.entity_key.to_s] = child_results
      else
        next unless entity.compute_enabled && entity.compute_type_id == 1
        next if entity.parent.present? && entity.parent.class.collection? # This is already computed in the if block
        form_data[entity.entity_key.to_s] = LiquidHelper.interpolate(entity.compute_formula, {'form'=>form_data})
      end
    end
    form_data
  end

  def process_form_data(form_data, is_admin = false)
    form_data[:form] = form
    form_data[:is_import_process] = true

    record_id = form_data[:id] || form_data['id']
    if record_id.present?
      form_data[:record_query] = { id: record_id }
    end

    #ToDo: use same operation once batch saving is resolved
    result = if is_admin
               Forms::Import::Ops::AdminCreate.(params: form_data, current_user: user)
             else
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

  def get_id_from_value(raw_value, entity)
    value_id_map[entity.gsub('*', '')][raw_value.to_s.strip] rescue nil
  end

  def get_dropdown_entity_value(raw_value, entity)
    return unless raw_value
    return unless entity

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
    return unless entity

    choice = entity.choices_scope.find_by_id(raw_value, user: user)
    return unless choice.present?

    choice_name = nil
    if choice.respond_to?(:name)
      choice_value = choice.name
    elsif choice.respond_to?(:display_name)
      choice_value = choice.display_name
    end
    {
      id: parse_value(choice[:id], entity),
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
