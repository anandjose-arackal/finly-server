class Forms::Import::Job < Transactions::API
  include Transactions::BackgroundWorker
  include Dry::Monads[:result]

  step Model(ImportJob, :find_by_uuid)
  step :init_form
  step :process_meta_data
  step :preprocess_import_job
  step :preprocess_import_record
  step :process_import


  def init_form(context, params:, model:, current_user:, **)
    form_key = params[:route].split(".")[1]
    context[:form] = Form.where(company_id: current_user.company.id, klass_name: Forms::Router.klass(form_key)&.name).first
  end

  def process_meta_data(context, params:, model:, current_user:, form:, **)
    return true unless params[:process_meta_data]

    context[:form_import] = Forms::Import::Processor.(form, current_user)
    context[:form_import].process_meta_data(model)
  end

  def preprocess_import_job(context, params:, model:, current_user:, form:, **)
    return true unless params[:preprocess_import_job]

    context[:form_import] = Forms::Import::Processor.(form, current_user)
    context[:form_import].preprocess_import_job(model)
  end

  def preprocess_import_record(context, params:, model:, current_user:, form:, **)
    return true unless params[:preprocess_import_record]

    record = model.records.find_by(uuid: params[:record_id])
    context[:form_import] = Forms::Import::Processor.(form, current_user)
    processed_data = context[:form_import].preprocess_import_record(record)

    record.processed_data = processed_data
    record.save

    processed_data
  end

  def process_import(context, params:, model:, current_user:, form:, **)
    return true unless params[:process_import]

    context[:form_import] = Forms::Import::Processor.(form, current_user)
    context[:form_import].process_import_records(model)
  end
end
