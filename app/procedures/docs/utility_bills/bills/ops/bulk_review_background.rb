class Docs::UtilityBills::Bills::Ops::BulkReviewBackground < Transactions::API

  include Transactions::BackgroundWorker

  step :pre_validate
  step :init
  step :process
  step :mail


  def pre_validate(options, params:, **)
    unless params['action_type'].present? || valid_actions.include?(params['action_type'].to_sym)
      add_message options, :error, :base, "Invalid Action Type"
      return
    end
    true
  end


  def init(options, params:, current_user:, **)
    ids = params['ids']

    index_op = Docs::UtilityBills::Bills::Ops::Index.(params: params, current_user: current_user)
    records = index_op['result']&.dig('bills').with_id(ids)
    options[:records] = records
    true
  end

  def process(options, params:, current_user:, records:, **)
    action_type = params['action_type']

    result = []
    records.each do |record|
      parameters = {
          aasm_event: action_type,
          id: record.id
      }

      op = Docs::UtilityBills::Bills::Ops::Review.(params: parameters, current_user: current_user)
      # data = {
      #     success: op.success?,
      #     messages: op.messages,
      #     record: record
      # }
      data = record.as_json

      data[:success] = op.success?
      data[:messages] = op.messages

      result.push(data)
    end

    options[:result] = result
    true
  end

  def mail(options, params:, result:, current_user:, **)
    params[:result] = result
    Docs::UtilityBills::Bills::Mailers::BulkReview.(params: params, current_user: current_user)
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
