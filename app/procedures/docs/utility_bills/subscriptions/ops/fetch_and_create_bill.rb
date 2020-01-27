class Docs::UtilityBills::Subscriptions::Ops::FetchAndCreateBill < Transactions::API

  step :init

  step Model(BbpsBillerSubscription, :find_by)

  step :validate

  step :set_params

  step :bill_fetch

  step :create_bill

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

  def bill_fetch(options, fetch_params:, **)
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

  def create_bill(options, model:, current_user:, result:, **)
    data = result['data']
    return if data.blank? || data&.status != 'Y'

    bill_date_year = DateUtils.parse_date(data&.bill_date)&.strftime("%Y")
    bill_period = data.bill_period

    # Find by bill Number if present
    if data.bill_number.present? && data.bill_number != "NA"
      bill = model.bbps_bills.where('bill_number = ?', data.bill_number).first
    elsif (data.bill_date.present? && data.bill_date != "NA") && (data.due_date.present? && data.due_date != "NA")
      bill = model.bbps_bills.where("bill_date = ? AND due_date = ?", DateUtils.parse_date(data.bill_date), DateUtils.parse_date(data.due_date)).first
    elsif data.bill_period.present? && data.bill_period != "NA"
      bill = model.bbps_bills.where('extract(year from bill_date) = ?', bill_date_year).where('lower(bill_period) = ?', bill_period.downcase).first
    else
      bill = nil
    end

    if bill.present?
      bill.update(order_number: data.ref_no, order_number_type: "BillFetch")
      add_message options, :error, :base, "Bill Already Exists"
      return true
    end

    bill_period = Date.today.strftime("%B").upcase if bill_period == "NA"

    params = {
        amount: (data.amount.to_f / 100).round(2),
        bill_date: data.bill_date,
        bill_number: data.bill_number,
        due_date: data.due_date,
        bill_period: bill_period,
        convenience_fee: get_amount_from_response(data.convenience_fee),
        convenience_fee_desc: data.convenience_fee_desc,
        early_payment_fee: get_amount_from_response(data.early_payment_fee),
        late_payment_fee: get_amount_from_response(data.late_payment_fee),
        subscription_id: subscription.id,
        autofetched: true,
        order_number: data.ref_no,
        order_number_type: "BillFetch"
    }
    op = Docs::UtilityBills::Bills::Ops::Create.(params: params, current_user: current_user)
    op.messages.each do |key, val|
      next if key == :errors_meta
      add_message options, key, :base, val
    end
    op.success?
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
