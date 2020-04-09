class Docs::UtilityBills::Complaints::Ops::Raise < Transactions::API

  schema do
    params do
      required(:mobile_number).filled
      required(:complaint_type).filled
      required(:complaint_category).filled
      required(:complaint_entity_id).filled
    end
  end

  step :init

  def init(options, params:, **)
    Bbps::ComplaintCreate.call_async({params: params, current_user: User.first}, {wait: true}) do |op|
      op.success do |op_result|
        result = {
            'complaint' => op_result
        }

        options['result'] = result
      end

      op.error do |op_result|
        result = {
            'complaint' => op_result
        }
        options['result'] = result
      end

      op.failure do |op_result|
        result = {
            'complaint' => op_result
        }
        options['result'] = result
      end
    end
    true
  end
end

