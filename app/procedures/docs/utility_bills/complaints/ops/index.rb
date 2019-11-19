class Docs::UtilityBills::Complaints::Ops::Index < Transactions::API
  step :init

  schema do
    params do
      required(:mobile_number).filled
    end
  end

  def init(options, params:, **)
    Bbps::ComplaintList.(params, "current_user" => User.first) do |op|
      op.success do |op_result|
        result = {
            'complaints' => op_result
        }

        options['result'] = result
      end

      op.failure do |op_result|
        # Send error response
      end
    end
  end
end