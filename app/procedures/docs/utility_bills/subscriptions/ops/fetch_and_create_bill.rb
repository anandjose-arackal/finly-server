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


    # New Code
    bill_date_year = Date.parse(data.bill_date).strftime("%Y")
    bill_period = data.bill_period
    bill = nil

    if (data.due_date.present? && data.due_date != "NA" && data.due_date != "9999-01-01") && (data.bill_date.present? && data.bill_date != "NA" && data.bill_date != "0001-01-01")
      bill = model.bbps_bills.where("bill_date = ? AND due_date = ?", Date.parse(data.bill_date), Date.parse(data.due_date))
    elsif data.due_date.present? && data.due_date != "NA" && data.due_date != "9999-01-01"
      bill = model.bbps_bills.where("due_date = ?", Date.parse(data.due_date))
    elsif data.bill_date.present? && data.bill_date != "NA" && data.bill_date != "0000-01-01"
      bill = model.bbps_bills.where("bill_date = ?", Date.parse(data.bill_date))
    elsif data.bill_period.present? && data.bill_period != "NA"
      # Received the following kinds of bill numbers
      # ["1", nil, "december", "march", "may", "Monthly", "JANUARY", "MONTHLY", "FEBRUARY", "0.0", "JAN 20", "202002", "DECEMBER"]

      if bill_periods.include?(bill_period.to_s.downcase) # Deals with Months
        bill = model.bbps_bills.where(bill_period: data.bill_period)
      elsif ["monthly"].includes?(bill_period.to_s.downcase) # Deals with Monthly; Also changes it to current month
        bill_period = Date.today.strftime("%b")
        bill = model.bbps_bills.where(bill_period: data.bill_period)
      elsif bill_periods.filter {|month| period.downcase.index(month)}.present? # Deals with 'JAN 20'
        bill_period = bill_periods.filter {|month| period.downcase.index(month)}[0]
        bill = model.bbps_bills.where(bill_period: data.bill_period)
      else
        # bill = model.bbps_bills.where("extract(year from created_at) = ?", Date.today.strftime("%Y")).where("extract(month from created_at) = ?", Date.today.strftime("%b"))
        Event::EAlert::Create.(nil,
            title: "Ambiguous Bill Creation Manually #{model.id} . #{bill&.id}",
            description: "Subscription: #{model.as_json} \n Bills: #{model.bbps_bills.last.as_json} \n Response: #{data.as_json["table"]}",
            subject: "Ambiguous Bill Creation #{model.id} . #{bill&.id}"
        )
      end
    else
      Event::EAlert::Create.(nil,
          title: "Ambiguous Bill Creation Manually #{model.id} . #{bill&.id}",
          description: "Subscription: #{model.as_json} \n Bills: #{model.bbps_bills.last.as_json} \n Response: #{data.as_json["table"]}",
          subject: "Ambiguous Bill Creation #{model.id} . #{bill&.id}"
      )
    end


    if bill.present?
      bill.update(order_number: data.ref_no, order_number_type: "BillFetch")
      add_message options, :error, :base, "Bill Already Exists"
      return true
    end

    bill_period = Date.today.strftime("%B").upcase if bill_period == "NA"

    params = {
        amount: (data.amount.to_d / 100).round(2),
        bill_date: data.bill_date,
        bill_number: data.bill_number,
        due_date: data.due_date,
        bill_period: bill_period,
        convenience_fee: get_amount_from_response(data.convenience_fee),
        convenience_fee_desc: data.convenience_fee_desc,
        early_payment_fee: get_amount_from_response(data.early_payment_fee),
        late_payment_fee: get_amount_from_response(data.late_payment_fee),
        subscription_id: model.id,
        autofetched: true,
        order_number: data.ref_no,
        order_number_type: "BillFetch"
    }
    op = Docs::UtilityBills::Subscriptions::Ops::Create.(params: params, current_user: current_user)
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
    if response.to_s.split("=").map(&:downcase).include?("circle")
      return 0
    else
      response.to_s.split("=")[1].to_f / 100
    end
  end
end
