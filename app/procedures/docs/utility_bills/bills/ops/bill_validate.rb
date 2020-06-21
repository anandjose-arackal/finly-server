class Docs::UtilityBills::Bills::Ops::BillValidate < Transactions::API

  step :init

  step Model(BbpsBill, :find_by)

  step :validate

  step :set_params

  step :bill_validate

  step :update_bill

  step Transactions::Messages::SuccessMessage('Successful')

  def init(options, params:, **)
    params[:id] = params[:bill_id]
  end

  def validate(options, model:, **)
    subscription = model.subscription
    biller = model.biller

    add_message(options, :error, :base, "Subscription not found") if subscription.blank?
    add_message(options, :error, :base, "Biller not found") if biller.blank?

    return false if (subscription.blank? || biller.blank?)

    options[:subscription] = subscription
    options[:biller] = biller

    true
  end

  def set_params(options, model:, subscription:, biller:, params:, **)
    param = {
        mobile_number: subscription.mobile_number,
        biller_id: biller.biller_id,
    }

    5.times do |ind|
      data = get_customer_params(subscription, ind + 1)
      param["customer_param_#{ind + 1}".to_sym] = data if data
    end

    param[:amount_1] = model.amount.value if model.amount.present? && model.amount.value > 0
    param[:amount_2] = model.late_payment_fee.value if model.late_payment_fee.present? && model.late_payment_fee.value > 0
    param[:amount_3] = model.early_payment_fee.value if model.early_payment_fee.present? && model.early_payment_fee.value > 0
    param[:amount_4] = model.convenience_fee.value if model.convenience_fee.present? && model.convenience_fee.value > 0

    options[:validation_params] = param
    true
  end

  def bill_validate(options, model:, validation_params:, **)
    options['result'] = {}
    # op = Bbps::BillValidation.call_async({params: validation_params, current_user: User.first}, {wait: true})
    # op = Bbps::BillValidation.call({params: validation_params, current_user: User.first})
    Bbps::BillValidation.call_async({params: validation_params, current_user: User.first}, {wait: true}) do |op|
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

    result = op.with_indifferent_access

    if result[:success]
      p "##############Result", result
      # model.update(validation_order_number: )
    end
    true
  end

  def update_bill(options, model:, result:, **)
    data = result['data']

    api_response = model&.api_response || []
    api_response.push(data.as_json&.dig("table").merge({created_at: DateTime.now, api_type: "BillValidate"}))

    update_params = {
        order_number: data.order_number,
        order_number_type: "BillValidate",
        bill_validation_required: false,
        api_response: api_response
    }

    model.update(update_params)
  end

  private

  def get_customer_params(subscription, index)
    return false if subscription.send("customer_param_key_#{index}").blank? || subscription.send("customer_param_value_#{index}").blank?
    data = {
        key: subscription.send("customer_param_key_#{index}"),
        value: subscription.send("customer_param_value_#{index}")
    }
  end

end
