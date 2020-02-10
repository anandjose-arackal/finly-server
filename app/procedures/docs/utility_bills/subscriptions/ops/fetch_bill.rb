class Docs::UtilityBills::Subscriptions::Ops::FetchBill < Transactions::API

  step :init

  step Model(BbpsBillerSubscription, :find_by)

  step :validate

  step :set_params

  step :bill_fetch

  step :check_bill_presence

  step :update_bill

  def init(options, params:, **)
    params[:id] = params[:subscription_id]
  end

  def validate(options, params:, model:, **)
    biller = model.biller

    if biller.blank?
      add_message(options, :error, :base, "Biller not found")
      return
    end

    unless ["MANDATORY", "OPTIONAL"].include?(biller.fetch_requirement)
      add_message(options, :error, :base, "Bill Fetch Not Supported for the Biller")
      return
    end

    true
  end

  def set_params(options, model:, params:, **)
    fetch_params = customer_params(model).with_indifferent_access
    options[:fetch_params] = fetch_params
    true
  end

  def bill_fetch(options, model:, fetch_params:, **)
    # op = Bbps::BillFetch.call_async({params: fetch_params, "current_user" => User.first}, {wait: true})
    options['result'] = {}
    Bbps::BillFetch.call_async({params: fetch_params, "current_user" => User.first}, {wait: true}) do |op|
      op.success do |result|
        p "SUCCESS"
        options['result']['data'] = result
      end

      op.error do |result|
        p "ERROR"
        options['result']['data'] = result
      end

      op.failure do |result|
        p "FAILURE"

        if result["errors"].present? && result["errors"].is_a?(Hash)
          messages = result["errors"].values.flatten
          add_message options, :error, :base, messages
        end
        return
      end
    end
    true
  end

  def check_bill_presence(options, model:, result:, **)

    if result['data'].status == 'Y'
      bill_date_year = Date.parse(result['data'].bill_date).strftime("%Y")
      bill_period = result['data'].bill_period
      bill = model.bbps_bills.where('extract(year from bill_date) = ?', bill_date_year).where('lower(bill_period) = ?', bill_period.downcase).first

      if bill.present?
        result['bill'] = bill
      end
    end

    true
  end

  def update_bill(options, result:, **)
    return true if result['bill'].blank?

    # Update Bill with Reference Number
    bill_update_params = {
        order_number: result['data'].ref_no,
        order_number_type: 'BillFetch'
    }

    # Create Contract

    # Validate Contract

    # Persist Contract

    result['bill'].update(order_number: result['data'].ref_no, order_number_type: "BillFetch")
  end

  private

  def customer_params(subscription)
    parameters = {
        mobile_number: subscription.mobile_number,
        biller_id: subscription.biller&.biller_id,
    }

    (1..5).to_a.each do |i|
      key = subscription.send("customer_param_key_#{i}")
      value = subscription.send("customer_param_value_#{i}")
      if key.present? && value.present?
        parameters["customer_param_#{i}"] = {
            key: key,
            value: value
        }
      end
    end
    parameters
  end

  def get_amount_from_response(response)
    return response.to_f unless response.to_s.include?("=")
    response.to_s.split("=")[1].to_f / 100
  end
end
