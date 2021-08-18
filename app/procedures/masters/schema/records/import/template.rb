class Masters::Schema::Records::Import::Template < Transactions::API

  schema do
    params do
      required(:master_key).filled
    end
  end

  step :find_schema
  step Policy::Pundit(Masters::Schema::Records::Policy, :import?)
  pass :init
  pass :build_headers
  pass :build_records_content
  pass :build_lookup_content
  pass :build_sheets
  pass :build_template

  def find_schema(context, params:, current_user:, **)
    context[:master_schema] = MasterSchema.find_by(company_id: current_user.company_id, master_key: params[:master_key])
  end

  def init(context, params:, current_user:, **)
    context[:sheets_data] = []
    context[:sheets] = []
  end

  def build_headers(context, params:, master_schema:, **)
    context[:headers] = []
    if master_schema.has_nesting
      context[:headers] << 'Parent ID'
    end
    master_schema.entities.only_active.each do |entity|
      context[:headers] << entity.label
    end

    context[:sheets] << {
      name: 'Sheet 1',
      item_headers: context[:headers],
      item_contents: []
    }
  end

  def build_records_content(context, master_schema:, current_user:, **)
    # return true unless master_schema.has_nesting

    sheet = {}
    sheet[:name] = master_schema.name
    sheet[:data] = Choices[:lookup].("masters.#{master_schema.master_key}").build(user: current_user).as_json

    context[:sheets_data] << sheet
  end

  def build_lookup_content(context, master_schema:, current_user:, **)
    master_schema.entities.only_active.each do |entity|
      next unless ['lookup', 'dropdown'].include?(entity.entity_type)

      sheet = {}
      sheet[:name] = entity.label
      if entity.entity_type == 'lookup'
        sheet[:data] = entity.choices_scope.build(user: current_user, params: { paginate: false }).as_json
      end

      if entity.entity_type == 'dropdown'
        if entity.choices.present?
          sheet[:data] = {
            choices: entity.choices.map do |choice|
              choice.as_json
            end
          }.with_indifferent_access
        else
          sheet[:data] = entity.choices_scope.build(user: current_user, params: { paginate: false }).as_json
        end
      end
      context[:sheets_data] << sheet
    end
  end

  def build_sheets(context, master_schema:, sheets_data:, current_user:, **)
    sheets_data.each do |sheet_data|
      sheet = {}
      sheet[:name] = sheet_data[:name]
      sheet[:item_headers] = []
      sheet[:item_contents] = []
      sheet_header_keys = []
      if sheet_data[:data][:headers].present?
        sheet_data[:data][:headers].each_with_index do |key_value, index|
          sheet_header_keys << key_value[0]
          sheet[:item_headers] << key_value[1][:label]
        end
      elsif sheet_data[:data][:choices].first.present?
        sheet_data[:data][:choices].first.each_with_index do |key_value, index|
          sheet_header_keys << key_value[0]
          sheet[:item_headers] << key_value[0].to_s.titleize
        end
      end

      sheet_data[:data][:choices].each_with_index do |row, row_index|
        row_data = []
        row = row.with_indifferent_access
        sheet_header_keys.each_with_index do |header_key, header_index|
          row_data << row[header_key.to_sym]
        end
        sheet[:item_contents] << row_data
      end

      context[:sheets] << sheet
    end
  end

  def build_template(context, headers:, sheets:, params:, current_user:, **)
    exporter = Exporter::Xlsx.new(current_user, { headers: headers, contents: [], sheets: sheets, expire_file_duration: 1.day }, {})
    context[:template] = exporter.export_file_path
  end
end
