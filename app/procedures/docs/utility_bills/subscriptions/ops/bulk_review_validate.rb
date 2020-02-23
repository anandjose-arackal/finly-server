class Docs::UtilityBills::Subscriptions::Ops::BulkReviewValidate < Transactions::API

  step :pre_validate
  step :init
  step :validate

  fail :test


  def pre_validate(options, params:, **)
    unless params[:action_type].present? || valid_actions.include?(params[:action_type].to_sym)
      add_message options, :error, :base, "Invalid Action Type"
      return
    end
    true
  end

  def init(options, params:, current_user:, **)
    ids = params[:ids]

    index_op = Docs::UtilityBills::Subscriptions::Ops::Index.(params: params, current_user: current_user)
    records = index_op['result'].dig('subscriptions')&.with_id(ids)
    options[:records] = records
    true
  end

  def validate(options, current_user:, params:, records:, **)
    result = []
    records.each do |record|
      policy = Docs::UtilityBills::Bills::Authorizer.new(current_user, record)

      data = record.as_json
      data["can_perform"] = policy.send((params['action_type'].to_s + '?').to_sym)

      result.push(data)
    end

    options[:result] = result
    true
  end

  def valid_actions
    [
        :approve,
        :reject,
        :take_control,
        :return_control
    ]
  end

  def test(ctx, options)
  end
end