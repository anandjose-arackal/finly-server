class Forms::Export::Processor
  include Writexlsx::Utility

  attr_accessor :form, :user

  NAME_MAP = {
    'Vendors': 'YesBankVendor',
    'Gstin locations': 'gstin_locations',
    'Bank accounts': 'bank_accounts'
  }

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
    sheets_headers[form.model.name] = {
      name: form.label,
      key: form.model.name,
      nested_entities: [],
      headers: {
        import_sequence_number: {
          name: "Import Sequence Number",
          entity_key: 'import_sequence_number',
          entity_type: 'text'
        },
        id: {
          name: "#{form.label&.singularize} Internal ID",
          entity_key: 'id',
          entity_type: 'text',
          hidden: true
        }
      }
    }

    form_sections.each do |section|
      section.entities.each do |entity|
        next unless entity.parent_id.blank?
        next unless (entity.visible || entity.conditions.joins(:actions).where(form_condition_actions: {property: :visible, value: true}).present?)

        sheets_headers[form.model.name][:headers].merge!(build_headers_for_entity(sheets_headers, form.label, form.model.name, entity, user))
      end
    end

    sheets_headers.with_indifferent_access
  end

  def build_headers_for_entity(sheets_headers, parent_sheet_label, parent_sheet_key, entity, user)
    headers = {}

    if entity.entities.blank?
      if (entity.visible || entity.conditions.joins(:actions).where(form_condition_actions: {property: :visible, value: true}).present?)
        if entity.entity_type == 'switch'
          headers[entity.entity_key.to_s] = {
            name: "#{entity.label}#{entity.required ? '*' : ''} (Yes/No)",
            entity_key: entity.entity_key,
            entity_type: entity.entity_type,
            entity: entity,
            hide_in_sheet: entity.hide_in_import
          }
        elsif ['lookup', 'dropdown'].include?(entity.entity_type)
          if parent_sheet_key == 'vendor'
            headers[entity.entity_key.to_s] = {
              name: "#{entity.label} ID#{entity.required ? '*' : ''}",
              entity_key: entity.entity_key,
              entity_type: entity.entity_type,
              entity: entity,
            }
            headers["#{entity.entity_key}_value"] = {
              name: entity.label,
              entity_key: "#{entity.entity_key}_value",
              entity_type: 'text',
              import_skip: true,
              lookup_value: true,
              choices_array: choices_array(entity),
              hidden: true,
              entity: entity
            }
          else
            headers["#{entity.entity_key.to_s}"] = {
              name: "#{entity.label}#{entity.required ? '*' : ''}",
              entity_key: "#{entity.entity_key}",
              entity_type: entity.entity_type,
              lookup_value: true,
              choices_array: choices_array(entity),
              hide_in_sheet: entity.hide_in_import,
              entity: entity
            }
          end
        elsif entity.entity_type == 'date'
          headers[entity.entity_key.to_s] = {
            name: "#{entity.label}#{entity.required ? '*' : ''} (YYYY-MM-DD)",
            entity_key: entity.entity_key,
            entity_type: entity.entity_type,
            entity: entity,
            hide_in_sheet: entity.hide_in_import
          }
        elsif entity.entity_type == 'datetime'
          headers[entity.entity_key.to_s] = {
            name: "#{entity.label}#{entity.required ? '*' : ''} (YYYY-MM-DD HH:MM:SS)",
            entity_key: entity.entity_key,
            entity_type: entity.entity_type,
            entity: entity,
            hide_in_sheet: entity.hide_in_import
          }
        elsif entity.entity_type == 'switch'
          headers[entity.entity_key.to_s] = {
            name: "#{entity.label}#{entity.required ? '*' : ''}",
            entity_key: entity.entity_key,
            entity_type: entity.entity_type,
            entity: entity,
            hide_in_sheet: entity.hide_in_import
          }
        elsif entity.entity_type == 'attachment'
          headers[entity.entity_key.to_s] = {
            name: "#{entity.label}#{entity.required ? '*' : ''}",
            entity_key: entity.entity_key,
            entity_type: entity.entity_type,
            entity: entity,
            hidden: true,
            hide_in_sheet: entity.hide_in_import
          }
        else
          headers[entity.entity_key.to_s] = {
            name: "#{entity.label}#{entity.required ? '*' : ''}",
            entity_key: entity.entity_key,
            entity_type: entity.entity_type,
            entity: entity,
            hide_in_sheet: entity.hide_in_import
          }
        end
      end
    else
      return {} if ['credit_note_adjustments'].include? entity.entity_key
      return {} if entity.hide_in_import

      child_sheet_headers = {
        parent_sequence_number: {
          name: "Import Sequence Number",
          entity_key: 'parent_sequence_number',
          entity_type: 'text'
        },
        parent_id: {
          name: "#{parent_sheet_label&.singularize} Internal ID",
          entity_key: 'parent_id',
          entity_type: 'text',
          hidden: true
        },
        id: {
          name: "#{entity.label&.singularize} Internal ID",
          entity_key: 'id',
          entity_type: 'text',
          hidden: true
        }
      }
      sheets_headers[entity.entity_key] = {
        name: entity.label,
        key: entity.entity_key,
        entity: entity,
        nested_entities: [],
      }
      entity.entities.each do |child_entity|
        next unless (child_entity.visible || child_entity.conditions.joins(:actions).where(form_condition_actions: {property: :visible, value: true}).present?)
        # next if child_entity.hide_in_import

        child_sheet_headers.merge!(build_headers_for_entity(sheets_headers, entity.entity_key, entity.entity_key, child_entity, user))
      end
      sheets_headers[entity.entity_key][:headers] = child_sheet_headers
      sheets_headers[parent_sheet_key][:nested_entities] << entity
    end

    headers
  end

  def choices_array(entity, user = self.user)
    return [] unless entity.choices_scope.present?

    entity.choices_scope.build(user: user, params: { paginate: false }).as_json[:choices].map(&:symbolize_keys).pluck(:name).map{|c| c[0..19]} rescue []
  end

  def build_lookup_content
    content = []

    form_sections.each do |section|
      # next unless section.associate_custom_fields
      section.entities.each do |entity|
        next unless ['lookup', 'dropdown'].include?(entity.entity_type)
        next unless (entity.visible || entity.conditions.joins(:actions).where(form_condition_actions: {property: :visible, value: true}).present?)
        next unless entity.choices_scope.present?

        content << {
          name: entity.label,
          data: entity.choices_scope.build(user: self.user, params: { paginate: false }).as_json
        }.with_indifferent_access
      end
    end

    content
  end

  def build_export(input, request)
    export_base = build_export_base(form.label)

    file = export_base[:file]
    workbook = export_base[:workbook]
    worksheets = export_base[:worksheets]

    set_lookup_content_in_export(workbook)
    set_documents_content_in_export(workbook, worksheets, input, request)

    workbook.close
    file.rewind

    request.result_file = file
    request.save
    request.progress_update(:completed)
  end

  def build_export_base(filename)
    file = Tempfile.new(["#{filename}_", '.xlsx'])
    workbook = ::WriteXLSX.new(file, strings_to_urls: false)

    worksheets = {}

    self.headers.values.each do |sheet_data|
      next if sheet_data[:hide_in_import]
      sheet_name = sheet_data[:name]
      sheet_key = sheet_data[:key]
      worksheets[sheet_key] = workbook.add_worksheet(sheet_name)
      self.headers[sheet_key][:headers].values.select{|header| header["hide_in_sheet"] == nil}.each_with_index do |header_data, header_index|
        next if header_data[:hide_in_sheet]
        width = (header_data[:hidden] || header_data[:entity_key] == 'status_id') ? 0 : header_data[:name].length+10
        worksheets[sheet_key].set_column(header_index, header_index, width)
        worksheets[sheet_key].write(0, header_index, header_data[:name].to_s)
      end
    end

    {
      file: file,
      workbook: workbook,
      worksheets: worksheets,
    }
  end

  def set_documents_content_in_export(workbook, worksheets, input, request)
    worksheets_length = Hash.new(0)

    input.each_with_index do |record, row_index|
      form_data = record.form_data(form).with_indifferent_access
      form_data['id'] = record.id

      self.headers.values.each do |sheet_data|
        sheet_name = sheet_data[:name]
        sheet_key = sheet_data[:key]
        if sheet_key == form.model.name
          worksheets_length[sheet_key] += 1
          self.headers[sheet_key][:headers].keys.each_with_index do |key, header_index|
            column_data = form_data[key]
            # get urls if attachments
            if column_data.is_a?(Array) && column_data.present? && column_data[0].is_a?(Hash) && column_data[0].has_key?(:url)
              column_data = (column_data.map { |d| d[:url] }).join("\n")
            end
            worksheets[sheet_key].write(1 + row_index, header_index, "\t" + column_data.to_s)
          end
        else
          parent_data = form_data
          form_data[sheet_key]&.each do |child_data|
            worksheets_length[sheet_key] += 1
            self.headers[sheet_key][:headers].keys.each_with_index do |key, header_index|
              column_data = child_data[key]
              if key.to_s == 'parent_id'
                column_data = parent_data['id']
              elsif key.to_s == 'parent_sequence_number'
                column_data = ''
              end
              # get urls if attachments
              if column_data.is_a?(Array) && column_data.present? && column_data[0].is_a?(Hash) && column_data[0].has_key?(:url)
                column_data = (column_data.map { |d| d[:url] }).join("\n")
              end
              worksheets[sheet_key].write(worksheets_length[sheet_key], header_index, "\t" + column_data.to_s)
            end
          end
        end
      end
      request.item_complete(true)
    end
  end

  def set_lookup_content_in_export(workbook)
    lookup_content.each_with_index do |content, index|
      begin
        worksheet = workbook.add_worksheet(content[:name])
      rescue
        next
      end

      sheet_header_keys = []

      if content[:data][:headers].present?
        content[:data][:headers].each_with_index do |key_value, index|
          sheet_header_keys << key_value[0]
          worksheet.set_column(index, index, key_value[1][:label].length+10)
          worksheet.write(0, index, "\t" + key_value[1][:label].to_s)
        end
      elsif content[:data][:choices].first.present?
        content[:data][:choices].first.each_with_index do |key_value, index|
          sheet_header_keys << key_value[0]
          worksheet.set_column(index, index, key_value[0].titleize.length+10)
          worksheet.write(0, index, "\t" + key_value[0].titleize)
        end
      end

      content[:data][:choices].each_with_index do |row, row_index|
        sheet_header_keys.each_with_index do |header_key, header_index|
          worksheet.write(1 + row_index, header_index, "\t" + row[header_key.to_sym].to_s)
        end
      end

      vendor_associations = {}
      if content[:name] == 'Vendor'
        vendor_ids = content[:data][:choices].map{|x| x['id']}
        vendor_associations = YesBankVendor.where(id: vendor_ids).includes(:bank_accounts, :gstin_locations).map{|x| [x.vendor_id, [x.gstin_locations.pluck(:location).join(', ' ),x.bank_accounts.pluck(:name).join(', ' )]]}.to_h
        begin
          association_worksheet = workbook.add_worksheet('Vendor Associations')
        rescue
          next
        end
        ['Vendor', 'Vendor Locations', 'Vendor Accounts'].each_with_index do |title, index|
          association_worksheet.set_column(0, index, title.length+10)
          association_worksheet.write(0, index, title)
        end
        vendor_associations.keys.each_with_index do |key, row_index|
          association_worksheet.write(1 + row_index, 0, key)
          association_worksheet.write(1 + row_index, 1, vendor_associations[key][0])
          association_worksheet.write(1 + row_index, 2, vendor_associations[key][1])
        end
      end

      # worksheet.hide if ['Status'].include? content[:name]
    end
  end

  # def add_xlookup_for_ids(workbook)
  #   sections = self.headers.values.pluck(:name)
  #   workbook.sheets.select {|x| sections.include? x.name }.each do |sheet|
  #     sheet_name = sheet.name
  #     data = self.headers[NAME_MAP[sheet_name.to_sym]]
  #     next unless data.present?
  #
  #     data['headers'].keys.each_with_index.each do |key, index|
  #       entity_type = data['headers'][key]['entity_type']
  #       if %w[lookup dropdown].include?(entity_type)
  #         name = data['headers'][key]['name']
  #         look_up_sheet_name = name.gsub(" ID*", "").gsub(" ID", "")
  #         Rails.logger.debug "Formula::=XLOOKUP(#{xl_rowcol_to_cell(2, index + 1)},'#{look_up_sheet_name}'!$B$2:$B$1048576,'#{look_up_sheet_name}'!$A$2:$A$1048576,0,0)"
  #         sheet.write_formula(1, index, "=XLOOKUP(#{xl_rowcol_to_cell(1, index + 1)},'#{look_up_sheet_name}'!$B$2:$B$1048576,'#{look_up_sheet_name}'!$A$2:$A$1048576,0,0)")
  #       elsif data['headers'][key][:lookup_value]
  #         # options = header_data[:choices_array] || ['True', 'False']
  #         name = data['headers'][key]['name']
  #         look_up_sheet_name = name.gsub(" ID*", "").gsub(" ID", "")
  #         Rails.logger.debug "ListValidation::#{name}::#{xl_rowcol_to_cell(1, index)}::#{"'#{look_up_sheet_name}'!B2:B1048576"}"
  #         sheet.data_validation(1, index, 1048575, index, {
  #           :validate => 'list',
  #           :source => "'#{look_up_sheet_name}'!$B$2:$B$1048576"
  #         })
  #       elsif entity_type == 'switch'
  #         sheet.data_validation(1, index, 1048575, index, {
  #           :validate => 'list',
  #           :source => %w[Yes No]
  #         })
  #       end
  #     end
  #   end
  # end
end
