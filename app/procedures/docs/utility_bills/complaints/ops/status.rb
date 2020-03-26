class Docs::UtilityBills::Complaints::Ops::Status < Transactions::API
  step :init

  schema do
    params do
      required(:complaint_id).filled
    end
  end

  def init(options, params:, **)
    Bbps::ComplaintStatus.call_async({params: params, current_user: User.first}, {wait: true}) do |op|
      op.success do |op_result|
        result = {}

        result.merge!(op_result)
        options['result'] = result
      end

      op.error do |op_result|
        result = {
            'status' => op_result
        }
        options['result'] = result
      end

      op.failure do |op_result|
        result = {
            'status' => op_result
        }
        options['result'] = result
      end
    end
  end
end