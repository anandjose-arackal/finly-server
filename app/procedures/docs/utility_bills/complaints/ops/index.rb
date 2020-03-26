class Docs::UtilityBills::Complaints::Ops::Index < Transactions::API
  step :init

  schema do
    params do
      required(:mobile_number).filled
    end
  end

  def init(options, params:, **)
    Bbps::ComplaintList.call_async({params: params, current_user: User.first}, {wait: true}) do |op|
      op.success do |op_result|
        result = {
            'complaints' => op_result
        }
        options['result'] = result
      end

      op.error do |op_result|
        result = {
            'complaints' => op_result
        }
        options['result'] = result
      end

      op.failure do |op_result|
        result = {
            'complaints' => op_result
        }
        options['result'] = result
      end
    end
    true
  end


end