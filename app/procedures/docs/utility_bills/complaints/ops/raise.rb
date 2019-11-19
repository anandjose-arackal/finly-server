class Docs::UtilityBills::Complaints::Ops::Raise < Transactions::API
  step :init

  schema do
    params do
      required(:mobile_number).filled
      required(:complaint_type).filled
      required(:complaint_category).filled
      required(:complaint_entity_id).filled
      optional(:description).filled
    end
  end

  def init(options, params:, **)
    Bbps::ComplaintCreate.(params, "current_user" => User.first) do |op|
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