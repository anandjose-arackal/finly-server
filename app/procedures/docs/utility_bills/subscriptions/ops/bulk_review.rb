class Docs::UtilityBills::Subscriptions::Ops::BulkReview < Transactions::API

  step :pre_validate
  step :init
  step :validate
  step :process
  step Transactions::Messages::SuccessMessage("Bulk Operation in Process. A Confirmation Mail will Be Sent with the Result upon Completion")


  def pre_validate(options, params:, **)
    unless params[:action_type].present? || valid_actions.include?(params[:action_type].to_sym)
      add_message options, :error, :base, "Invalid Action Type"
      return
    end
    true
  end


  def init(options, params:, current_user:, **)
    params[:ids] = params[:ids]

    index_op = Docs::UtilityBills::Subscriptions::Ops::Index.(params: params, current_user: current_user)
    records = index_op['result']&.dig('subscriptions').with_id(params[:ids])
    options[:records] = records
    true
  end

  def validate(options, current_user:, params:, records:, **)
    performable_record_ids = []
    records.each do |record|
      policy = Docs::UtilityBills::Subscriptions::Authorizer.new(current_user, record)

      if policy.send((params['action_type'].to_s + '?').to_sym)
        performable_record_ids.push(record.id)
      end
    end

    options[:performable_record_ids] = performable_record_ids
    true
  end

  def process(options, params:, performable_record_ids:, current_user:, **)
    params[:ids] = performable_record_ids
    params[:performed_at] = DateTime.now
    Docs::UtilityBills::Subscriptions::Ops::BulkReviewBackground.call_async(params: params, current_user: current_user)
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
end