class Admin::Masters::Macros::Jobs::Create < Admin::Transactions::API

  schema do
    params do
      # Marco ID
      required(:id).filled
    end
  end

  step Model(Macro, :find_by_id)
  step Policy::Pundit(Admin::Masters::Macros::Jobs::Policy, :create?)
  step :run!
  step Transactions::Messages::SuccessMessage('Initiated the execution of macro')

  def run!(context, model:, params:, **)
    params[:macro_id] = params[:id]
    MacrosConnector::Run.(params: params.except(:controller, :action, :format), current_user: model.user) do |m|
      m.success {|result| return true}
      m.failure {|result| return on_error(context, :base, result.errors[:base])}
    end

    true
  end

end