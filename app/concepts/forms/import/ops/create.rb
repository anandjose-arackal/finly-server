class Forms::Import::Ops::Create < Transactions::API
  step :set_form
  step :find_or_new_model
  step AssignModelUser(key: :created_by)
  step Forms::Contracts::Build()
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Record Saved')

  def set_form(context, params:, current_user:, **)
    context[:form] = params.delete(:form)
    true
  end

  def find_or_new_model(context, form:, params:, current_user:, **)
    context[:model] = if params[:record_query].present?
                        form.model.find_by(params[:record_query])
                      else
                        form.model.new
                      end
    true
  end
end
