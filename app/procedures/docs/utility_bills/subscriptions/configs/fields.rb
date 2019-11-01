class Docs::UtilityBills::Subscriptions::Configs::Fields < Transactions::API

  schema do
    params do
      optional(:type).filled
    end
  end

  step :init

  def init(options, params:, **)

  end
end