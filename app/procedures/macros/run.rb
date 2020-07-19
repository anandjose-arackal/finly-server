class Macros::Run < Transactions::API

  schema do
    params do
      # Marco ID
      required(:id).filled
    end
  end

  step Model(Macro, :find_by_id)
  step Policy::Pundit(Macros::Policy, :run?)
  step :run!

  def run!(context, model:, params:, current_user:, **)
    MacrosConnector::Run.(params: params, current_user: current_user) do |m|
      m.success { |result| return true }
      m.failure { |result| return on_error(context, :error, 'in request') }
    end

    true
  end

end