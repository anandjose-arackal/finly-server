class Forms::Import::Processor
  attr_accessor :form, :user, :export_processor

  def initialize(form, user)
    self.form = form
    self.user = user
    self.export_processor = Forms::Export::Processor.(form, user)
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
    file = Tempfile.new([form.model.name, '.xlsx'])
    workbook  = ::WriteXLSX.new(file, strings_to_urls: false)

    worksheets = {}
    worksheets_length = Hash.new(0)

    self.headers.values.each do |sheet_data|
      sheet_name = sheet_data[:name]
      sheet_key = sheet_data[:key]
      worksheets[sheet_key] = workbook.add_worksheet(sheet_name)
      worksheets_length[sheet_key] = 0
      self.headers[sheet_key][:headers].values.each_with_index do |header_data, header_index|
        worksheets[sheet_key].write(0, header_index, header_data[:name])
      end
    end

    lookup_content.each_with_index do |content, index|
      worksheet = workbook.add_worksheet(content[:name])

      sheet_header_keys = []

      if content[:data][:headers].present?
        content[:data][:headers].each_with_index do |key_value, index|
          sheet_header_keys << key_value[0]
          worksheet.write(0, index, key_value[1][:label])
        end
      elsif content[:data][:choices].first.present?
        content[:data][:choices].first.each_with_index do |key_value, index|
          sheet_header_keys << key_value[0]
          worksheet.write(0, index, key_value[0].titleize)
        end
      end

      content[:data][:choices].each_with_index do |row, row_index|
        sheet_header_keys.each_with_index do |header_key, header_index|
          worksheet.write(1 + row_index, header_index, row[header_key.to_sym])
        end
      end
    end

    workbook.close

    file.rewind

    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 1.day)
    temp_file.file
  end

  def process_import(request)
    path = Rails.env.production? ? request.request_file&.url : request.request_file&.path
    imported_sheet = Roo::Spreadsheet.open(path)

    file = Tempfile.new([form.model.name, '.xlsx'])
    workbook = ::WriteXLSX.new(file, strings_to_urls: false)

    data_headers = {}
    self.headers.values.each do |sheet_data|
      data_headers[sheet_data[:name]] = sheet_data[:key]
    end

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
          row_data[worksheet_headers[index]] = value
        end

        data = {}.with_indifferent_access

        header_details = headers[data_headers[sheet_name]][:headers]

        existing_record = nil
        if row_data[header_details[:id][:name]].present?
          existing_record = headers[data_headers[sheet_name]][:entity].populate_if_empty&.find(row_data[header_details[:id][:name]])
        end
        header_details.values.each do |header_data|
          if ['dropdown'].include?(header_data[:entity_type])
            data[header_data[:entity_key]] = header_data[:entity].choices_scope.find_by_name(row_data[header_data[:name]])&.dig(:id)
          elsif ['lookup'].include?(header_data[:entity_type])
            data[header_data[:entity_key]] = header_data[:entity].choices_scope.find_by_name(row_data[header_data[:name]], user: user)&.id
          elsif ['attachment'].include?(header_data[:entity_type])
            if existing_record.present?
              field = existing_record.form_custom_fields.joins(:form_entity).where("form_entities.entity_key = ?", header_data[:entity_key]).first
              data[header_data[:entity_key]] = field.attachments.as_json if field.present?
            end
          else
            data[header_data[:entity_key]] = parse_value(row_data[header_data[:name]], header_data[:entity])
          end
        end

        unless data[:id].present?
          data.delete(:id)
        end

        if data[:parent_id].present?
          key = data[:parent_id].to_s
          nested_data[data_headers[sheet_name]][key] = [] unless nested_data[data_headers[sheet_name]][key].present?
          nested_data[data_headers[sheet_name]][key] << data
        end
      end
    end

    imported_sheet.each_with_pagename do |sheet_name, sheet|
      worksheet = workbook.add_worksheet(sheet_name)

      worksheet_headers = sheet.row(1)
      if sheet_name == form.label
        worksheet_headers << 'Message'
      end

      worksheet_headers.each_with_index do |header_name, header_index|
        worksheet.write(0, header_index, header_name)
      end

      if sheet_name == form.label
        (2..sheet.last_row).each do |index|
          row_data = {}.with_indifferent_access
          row = sheet.row(index)
          row.each_with_index do |value, column_index|
            row_data[worksheet_headers[column_index]] = value
          end

          header_details = headers[data_headers[sheet_name]][:headers]

          existing_record = nil
          if row_data[header_details[:id][:name]].present?
            existing_record = form.model.find(row_data[header_details[:id][:name]])
          end

          form_data = {}.with_indifferent_access
          header_details.values.each do |header_data|
            if ['dropdown'].include?(header_data[:entity_type])
              form_data[header_data[:entity_key]] = header_data[:entity].choices_scope.find_by_name(row_data[header_data[:name]], user: user)&.dig(:id)
            elsif ['lookup'].include?(header_data[:entity_type])
              form_data[header_data[:entity_key]] = header_data[:entity].choices_scope.find_by_name(row_data[header_data[:name]], user: user)&.id
            elsif ['attachment'].include?(header_data[:entity_type])
              if existing_record.present?
                field = existing_record.form_custom_fields.joins(:form_entity).where("form_entities.entity_key = ?", header_data[:entity_key]).first
                form_data[header_data[:entity_key]] = field.attachments.as_json if field.present?
              end
            else
              form_data[header_data[:entity_key]] = parse_value(row_data[header_data[:name]], header_data[:entity])
            end
          end

          nested_data.keys.each do |key|
            if form_data[:id].present?
              form_data[key] = nested_data[key][form_data[:id]]
            end
          end

          form_data[:form] = form
          form_data[:is_import_process] = true

          if form_data[:id].present?
            form_data[:record_query] = { id: form_data[:id] }
          end

          # byebug
          result = Forms::Import::Ops::Create.(params: form_data, current_user: user)
          if result.success?
            request.item_complete(true)
            row[0] = result[:model].id
            row << result.messages[:success].to_s
          else
            request.item_complete(false)
            row << result.messages[:errors].to_s
          end
          worksheet_headers.each_with_index do |header_name, header_index|
            worksheet.write(index - 1, header_index, row[header_index])
          end
        end
      else
        (2..sheet.last_row).each do |index|
          row = sheet.row(index)
          worksheet_headers.each_with_index do |header_name, header_index|
            worksheet.write(index - 1, header_index, row[header_index])
          end
        end
      end
    end

    # imported_sheet.each_with_pagename do |sheet_name, sheet|
    #   worksheet = workbook.add_worksheet(sheet_name)

    #   worksheet_headers = sheet.row(1)
    #   if sheet_name == form.model.name
    #     worksheet_headers << 'Message'
    #   end

    #   worksheet_headers.each_with_index do |header_name, header_index|
    #     worksheet.write(0, header_index, header_name)
    #   end

    #   if sheet_name == form.model.name

    #     request.update(requested_items: sheet.last_row - 1)

    #     (2..sheet.last_row).each do |index|
    #       row = sheet.row(index)
    #       result = process_row(row, worksheet_headers)
    #       if result.success?
    #         request.item_complete(true)
    #         row[0] = result[:model].id
    #         row << result.messages[:success].to_s
    #       else
    #         request.item_complete(false)
    #         row << result.messages[:errors].to_s
    #       end
    #       worksheet_headers.each_with_index do |header_name, header_index|
    #         worksheet.write(index - 1, header_index, row[header_index])
    #       end
    #     end
    #   else
    #   end
    # end

    workbook.close

    file.rewind

    request.result_file = file
    request.save
    request.progress_update(:completed)
  end

  def process_row(row, worksheet_headers)
    header_keys = {}
    headers.each do |key, value|
      header_keys[value] = key
    end

    row_data = {}.with_indifferent_access
    row.each_with_index do |value, index|
      row_data[header_keys[worksheet_headers[index]]] = value
    end

    form_data = { id: row_data[:id] }.with_indifferent_access

    existing_record = nil
    if row_data[:id].present?
      existing_record = form.model.find(row_data[:id])
    end

    form_sections.each do |section|
      section.entities.each do |entity|
        next unless entity.parent_id.blank?
        next if entity.type == 'FormEntity::Attachment'

        form_data.merge!(get_entity_value(row_data, entity, existing_record))
      end
    end

    form_data[:form] = form

    if form_data[:id].present?
      form_data[:record_query] = { id: form_data[:id] }
    end

    Forms::Import::Ops::Create.(params: form_data, current_user: user)
  end

  def get_entity_value(row_data, entity, existing_record)
    data = {}.with_indifferent_access
    return data if entity.entity_type == 'attachment'

    if entity.entities.blank?
      data[entity.entity_key.to_s] = parse_value(row_data[entity.entity_path], entity)
    else
      children_data = {}.with_indifferent_access
      record_finder_query = {}
      entity.entities.each do |child_entity|
        children_data.merge!(get_entity_value(row_data, child_entity, existing_record))
      end
      data[entity.entity_key.to_s] = [children_data]
    end

    data
  end

  def parse_value(value, entity)
    unless entity.present?
      return value.to_s.strip
    end

    if value.present?
      if value.is_a?(Float) || value.is_a?(Integer)
        if ['number', 'amount'].include?(entity.entity_type)
          return value
        end

        value = value.to_i.to_s
      end

      value = value.to_s.strip
      return value
    end

    entity.default_value
  end
end
