class Forms::Import::Processor
  attr_accessor :form, :user

  def initialize(form, user)
    self.form = form
    self.user = user
  end

  def self.call(form, user)
    self.new(form, user)
  end

  def headers
    @headers ||= build_headers
  end

  def lookup_content
    @lookup_content ||= build_lookup_content
  end

  def form_sections
    @form_sections ||= form.sections.includes(entities: { entities: { entities: { entities: :entities } } })
  end

  def build_headers
    headers = { id: 'ID' }.with_indifferent_access

    form_sections.each do |section|
      next unless section.associate_custom_fields

      section.entities.each do |entity|
        next unless entity.parent_id.blank?
        next unless entity.visible
        next if entity.type == 'FormEntity::Attachment'

        headers.merge!(build_headers_for_entity(entity, user))
      end
    end

    headers
  end

  def build_headers_for_entity(entity, user)
    headers = {}

    if entity.entities.blank?
      if entity.visible && entity.type != 'FormEntity::Attachment'
        headers[entity.entity_path.to_s] = entity.entity_key.titleize(keep_id_suffix: true)
        if entity.type == 'FormEntity::Switch'
          headers[entity.entity_path.to_s] += ' (Y/N)'
        end
      end
    else
      entity.entities.each do |child_entity|
        next unless child_entity.visible
        next unless entity.type != 'FormEntity::Attachment'

        build_headers_for_entity(child_entity, user).each do |hdr_key, hdr_value|
          headers[hdr_key] = "#{entity.entity_key.titleize(keep_id_suffix: true)} #{hdr_value}"
        end
      end
    end

    headers
  end

  def build_lookup_content
    content = []

    form.sections.each do |section|
      next unless section.associate_custom_fields

      section.entities.each do |entity|
        next unless entity.visible
        next unless (entity.type == 'FormEntity::Lookup') || (entity.type == 'FormEntity::DropDown')
        next unless entity.choices_scope.present?

        content << {
          name: entity.label,
          data: entity.choices_scope.build(user: self.user).as_json
        }.with_indifferent_access
      end
    end

    content
  end

  def build_import_template
    file = Tempfile.new([form.model.name, '.xlsx'])
    workbook  = ::WriteXLSX.new(file)

    worksheet = workbook.add_worksheet(form.model.name)
    self.headers.values.each_with_index do |header_name, header_index|
      worksheet.write(0, header_index, header_name)
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

    input = Roo::Spreadsheet.open(path)
    output = {}

    file = Tempfile.new([form.model.name, '.xlsx'])
    workbook = ::WriteXLSX.new(file)

    imported_headers = {}

    input.each_with_pagename do |sheet_name, sheet|
      output[sheet_name] = []

      worksheet = workbook.add_worksheet(sheet_name)

      worksheet_headers = sheet.row(1)
      if sheet_name == form.model.name
        worksheet_headers << 'Message'
      end

      worksheet_headers.each_with_index do |header_name, header_index|
        worksheet.write(0, header_index, header_name)
      end

      if sheet_name == form.model.name

        request.update(requested_items: sheet.last_row - 1)

        (2..sheet.last_row).each do |index|
          row = sheet.row(index)
          result = process_row(row, worksheet_headers)
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

      if existing_record.present? && entity.class.collection? && entity.primary_key_for_import.present? && children_data[entity.primary_key_for_import].present?
        children_record = existing_record.send(entity.entity_key).where("#{entity.primary_key_for_import}": children_data[entity.primary_key_for_import]).first
        children_data[:id] = children_record.id if children_record.present?
      end
      data[entity.entity_key.to_s] = [children_data]
    end

    data
  end

  def parse_value(value, entity)
    if value.present?
      if value.is_a?(Float) || value.is_a?(Integer)
        if ['FormEntity::Number', 'FormEntity::Amount'].include?(entity.type)
          return value
        end

        value = value.to_i.to_s
      end

      value = value.to_s.strip
      if entity.type == 'FormEntity::Switch'
        return value.upcase == 'Y'
      end

      return value
    end

    entity.default_value
  end
end
