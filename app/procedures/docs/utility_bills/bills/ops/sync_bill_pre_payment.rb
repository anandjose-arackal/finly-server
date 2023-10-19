class Docs::UtilityBills::Bills::Ops::SyncBillPrePayment < Transactions::API

  step :init

  step :validate

  step :process

  step :validate_bill

  step :update_bill

  def init(options, params:, **)
    options[:bill] = BbpsBill.find_by id: params[:bill_id]
    options[:subscription] = options[:bill]&.subscription
    options[:biller] = options[:subscription]&.biller

  end

  def validate(options, subscription:, bill:, biller:, **)
    if bill.blank? or subscription.blank? or biller.blank?
      add_message(options, :error, :base, "Bill or Subscription not found")
      return false
    end

    # unless ["MANDATORY", "OPTIONAL"].include?(biller.fetch_requirement)
    #   add_message(options, :error, :base, "Bill Fetch Not Supported for the Biller")
    #   return
    # end

    if bill.expired? # todo check for expired? method
      add_message(options, :error, :base, "Bill has expired")
      return false
    end

    new_bills = subscription.bbps_bills.where("created_at > ?", bill.created_at)

    if new_bills.present?
      add_message(options, :error, :base, "Bill has expired; New Bill(s) Available in Finly [#{new_bills.pluck(:sequence_id).join(", ")}]")
      return false
    end

    true
  end

  def process(options, subscription:, biller:, **)
    if subscription.auto_fetchable
      bill_fetch(options, subscription)
    else
      bill_validate(options, subscription)
    end
  end

  def bill_fetch(options, subscription)
    options['result'] = {}
    options['success'] = false
    Bbps::BillFetch.call_async({params: subscription.generate_billfetch_params, current_user: User.first}, {wait: true, wait_timeout: 180.seconds}) do |op|
      op.success do |result|
        options['success'] = true
        options['result']['data'] = result
      end

      op.error do |result|
        options['success'] = false
        options['result']['data'] = result
        error_message = result["error_desc"]
        
        if error_message.present?
          add_message options, :error, :base, error_message
        end
        return false
      end

      op.failure do |result|
        error_message = result&.dig("result.operation.errors")&.dig("base")&.first

        if error_message.present?
          add_message options, :error, :base, error_message
        elsif result["error_desc"].present?
          add_message options, :error, :base, result["error_desc"]
        else
          add_message options, :error, :base, "Unable to Reach BBPS; Please Retry Later"
        end
        return false
      end
    end
    true
  end

  def bill_validate(options, subscription)
    options['result'] = {}
    options['success'] = false
    Bbps::BillValidation.call_async({params: subscription.generate_billfetch_params, current_user: User.first}, {wait: true, wait_timeout: 180.seconds}) do |op|
      op.success do |result|
        options['success'] = true
        options['result']['data'] = result
     end

      op.error do |result|
        options['success'] = false
        options['result']['data'] = result
      end

      op.failure do |result|
        error_message = result&.dig("result.operation.errors")&.dig("base")&.first

        if error_message.present?
          add_message options, :error, :base, error_message
        else
          add_message options, :error, :base, "Unable to Reach BBPS; Please Retry Later"
        end
        return false
      end
    end
    true
  end

  def validate_bill(options, subscription:, bill:, result:, **)
    return false unless options['success']
    
    data = result['data']
    amount = (data.amount.to_f / 100).round(2)

    return true unless subscription.auto_fetchable
    return true if bill.amount&.value == amount
    if amount == 0
      add_message(options, :error, :base, "Current outstanding balance for this bill is 0 and hence can not be paid ") if bill.amount != amount
    else
     add_message(options, :error, :base, "New Bill Available with Updated Amount") if bill.amount != amount
    end
    false
  end

  def update_bill(options, subscription:, bill:, result:, **)
    # Update Bill with new Reference Number
    bill_update_params = {order_number: result['data'].ref_no}


    if subscription.auto_fetchable

      bill_parse_op = Docs::UtilityBills::Bills::Ops::BillParser.(params: {data: result['data']}, current_user: User.first)

      parsed_bill_data = bill_parse_op[:result]

      bill.assign_attributes(parsed_bill_data.slice(
          :bill_date, :bill_number, :due_date, :bill_month,
          :bill_period, :early_payment_date))

      api_response = bill.api_response.is_a?(Array) ? bill.api_response : []
      api_response.push(parsed_bill_data[:api_response][0].merge({fetch_type: 'PrePaymentFetch'}))

      bill_update_params.merge({
                                   api_response: api_response,
                                   biller_response: bill.generate_changelog_message("Bill updated at BBPS. Updated ")
                               })
    else 
      bill_update_params = {order_number: result['data'].order_number}
    end

    bill.assign_attributes(bill_update_params)

    bill.save
  end

end
