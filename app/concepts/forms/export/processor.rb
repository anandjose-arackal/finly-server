class Forms::Export::Processor
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
    sheets_headers = {}
    sheets_headers[form.label] = { id: 'ID' }

    form_sections.each do |section|
      section.entities.each do |entity|
        next unless entity.parent_id.blank?
        next unless entity.visible

        sheets_headers[form.label].merge!(build_headers_for_entity(sheets_headers, form.label, entity, user))
      end
    end

    sheets_headers.with_indifferent_access
  end

  def build_headers_for_entity(sheets_headers, parent_sheet_name, entity, user)
    headers = {}

    if entity.entities.blank?
      if entity.visible
        unless ['lookup', 'dropdown'].include?(entity.entity_type)
          headers[entity.entity_key.to_s] = entity.entity_key.titleize(keep_id_suffix: true)
        end
        if entity.type == 'FormEntity::Switch'
          headers[entity.entity_key.to_s] += ' (Y/N)'
        end
        if ['lookup', 'dropdown'].include?(entity.entity_type)
          headers["#{entity.entity_key}_value"] = entity.label
        end
      end
    else
      child_sheet_headers = {
        parent_id: "#{parent_sheet_name.singularize} ID",
        parent_primary_key: "#{parent_sheet_name.singularize} #{form.primary_key_for_import.titleize(keep_id_suffix: true)}",
      }
      entity.entities.each do |child_entity|
        next unless child_entity.visible

        child_sheet_headers.merge!(build_headers_for_entity(sheets_headers, entity.entity_key, child_entity, user))
      end
      sheets_headers[entity.entity_key] = child_sheet_headers
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

  def build_export(input, request)
    file = Tempfile.new(["#{form.label}_", '.xlsx'])
    workbook = ::WriteXLSX.new(file)

    worksheets = {}
    worksheets_length = Hash.new(0)
    self.headers.keys.each do |sheet_name|
      worksheets[sheet_name] = workbook.add_worksheet(sheet_name.titleize)
      worksheets_length[sheet_name] = 0
      self.headers[sheet_name].values.each_with_index do |header_name, header_index|
        worksheets[sheet_name].write(0, header_index, header_name)
      end
    end

    input.each_with_index do |record, row_index|
      form_data = record.form_data(form).with_indifferent_access
      form_data['id'] = record.id

      self.headers.keys.each do |sheet_name|
        if sheet_name == form.label
          worksheets_length[sheet_name] += 1
          self.headers[sheet_name].keys.each_with_index do |key, header_index|
            column_data = form_data[key]
            # get urls if attachments
            if column_data.is_a?(Array) && column_data.present? && column_data[0].is_a?(Hash) && column_data[0].has_key?(:url)
              column_data = (column_data.map { |d| d[:url]}).join("\n")
            end
            worksheets[sheet_name].write(1 + row_index, header_index, column_data)
          end
        else
          parent_data = form_data
          form_data[sheet_name]&.each do |child_data|
            # byebug
            worksheets_length[sheet_name] += 1
            self.headers[sheet_name].keys.each_with_index do |key, header_index|
              column_data = child_data[key]
              if key.to_s == 'parent_id'
                column_data = parent_data['id']
              elsif key.to_s == 'parent_primary_key'
                column_data = parent_data[form.primary_key_for_import]
              end
              # get urls if attachments
              if column_data.is_a?(Array) && column_data.present? && column_data[0].is_a?(Hash) && column_data[0].has_key?(:url)
                column_data = (column_data.map { |d| d[:url]}).join("\n")
              end
              worksheets[sheet_name].write(worksheets_length[sheet_name], header_index, column_data)
            end
          end
        end
      end
      request.item_complete(true)
    end

    # self.headers.values.each_with_index do |header_name, header_index|
    #   worksheet.write(0, header_index, header_name)
    # end

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

    request.result_file = file
    request.save
    request.progress_update(:completed)
  end
end
