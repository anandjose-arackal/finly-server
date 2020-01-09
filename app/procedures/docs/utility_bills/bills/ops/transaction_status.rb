class Docs::UtilityBills::Bills::Ops::TransactionStatus < Transactions::API

  step :init

  step Model(BbpsBill, :find_by)

  step :validate

  step :set_params

  step :transaction_status

  step :update_bill

  step Transactions::Messages::SuccessMessage('Successful')

  def init(options, params:, **)
    params[:id] = params[:bill_id]
  end

  def validate(options, model:, **)
    add_message(options, :error, :base, "Cannot check transaction status at this state") if model.order_number.blank?
    true
  end

  def set_params(options, model:, subscription:, biller:, params:, **)
    param = {
        order_number: model.order_number
    }

    options[:transaction_status_params] = param
    true
  end

  def transaction_status(options, model:, transaction_status_params:, **)
    options['result'] = {}
    Bbps::TransactionStatus.call_async({params: transaction_status_params, current_user: User.first}, {wait: true}) do |op|
      op.success do |result|
        p "SUCCESS"
        Rails.logger.fatal "RESULT \n #{result.inspect}"
        options['result']['data'] = result
        return true
      end

      op.error do |result|
        p "ERROR"
        options['result']['data'] = result
        return
      end

      op.failure do |result|
        if result["errors"].present? && result["errors"].is_a?(Hash)
          messages = result["errors"].values.flatten
          add_message options, :error, :base, messages
        end
        return
      end
    end
    true
  end

  def update_bill(options, model:, result:, **)
    # todo Update bill & payment with status
    # order_number = result['data'].order_number
    # model.update(order_number: order_number, order_number_type: "BillValidate", bill_validation_required: false)
    true
  end

end
