class Masters::Schema::Records::Import::Create < Transactions::API

  schema do
    params do
      required(:master_key).filled
      required(:file).filled
    end
  end

  step :find_schema
  # Todo check user permission to ensure he can import masters
  step Policy::Pundit(Masters::Schema::Records::Policy, :import?)
  pass :build_headers
  pass :import_data

  def find_schema(context, params:, current_user:, **)
    context[:master_schema] = MasterSchema.find_by(company_id: current_user.company_id, master_key: params[:master_key])
  end

  def build_record_model(context, master_schema:, **)
    context[:record_model] = master_schema.record_model
  end

  def build_contract(context, master_schema:, **)
    context[:contract] = master_schema.contract
  end

  def build_headers(context, params:, master_schema:, **)
    context[:headers] = {}
    context[:sequence] = nil
    master_schema.entities.each do |entity|
      context[:headers][entity.entity_key] = entity.label
      context[:sequence] = entity.entity_key if entity.class.registered_type == 'sequence'
    end
  end

  def import_data(context, contract:, record_model:, params:, **)
    context[:result] = [
        # Append the headers
        context[:headers].values
    ]
    spreadsheet = ImportUtil.open_spreadsheet(params[:file])
    spreadsheet.sheet(0).each(context[:headers]) do |row|
      data = row.values
      data << import_row(context, contract, record_model, row)
      context[:result] << data
    end
  end

  def build_result(context, contract, result:, **)
    #
  end

  protected

  def import_row(context, contract_klass, record_model, row)

    record_model.where(company_id: context[:current_user].company_id)

    record = record_model.new(row)
    contract = contract_klass.new(record)
    unless contract.validate(row)
      return contract.errors.full_messages.join(",")
    end

    contract.save

    'Saved'
  end

end