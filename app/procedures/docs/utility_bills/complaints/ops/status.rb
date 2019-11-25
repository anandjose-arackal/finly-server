class Docs::UtilityBills::Complaints::Ops::Status < Transactions::API
  step :init

  schema do
    params do
      required(:complaint_id).filled
    end
  end

  def init(options, params:, **)
    Bbps::ComplaintStatus.(params, "current_user" => User.first) do |op|
      op.success do |op_result|
        result = {}

        result.merge!(op_result)
        options['result'] = result
      end

      op.failure do |op_result|
        # Send error
      end
    end
  end
end