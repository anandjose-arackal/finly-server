class Masters::Schema::Records::Import::Template < Transactions::API

  schema do
    params do
      required(:master_key).filled
      optional(:template_format).value(included_in?: %w(xls csv))
    end
  end

  step :find_schema
  step Policy::Pundit(Masters::Schema::Records::Policy, :import?)
  pass :build_headers
  pass :build_template

  def find_schema(context, params:, current_user:, **)
    context[:master_schema] = MasterSchema.find_by(company_id: current_user.company_id, master_key: params[:master_key])
  end

  def build_headers(context, params:, master_schema:, **)
    context[:headers] = []
    master_schema.entities.each do |entity|
      context[:headers] << entity.label
    end
  end

  def build_template(context, headers:, params:, current_user:, **)
    format = params[:template_format] || 'csv' # Default format is CSV
    exporter = Exporter::Spreadsheet.new(current_user, {headers: headers, contents: []}, {})
    file = exporter.send("generate_#{format}_file") # calling generate_csv_file / generate_xls_file functions in exporter
    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 1.day)
    context[:template] = temp_file.file.url
  end

end