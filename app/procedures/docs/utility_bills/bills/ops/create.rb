class Docs::UtilityBills::Bills::Ops::Create < Transactions::API

  step Model(BbpsBill, :new)

  # step Policy::Pundit( Docs::UtilityBills::Bills::Authorizer, :create? )

  step :check_bill_presence

  step :set_default_params

  step Contract::Build(constant: Docs::UtilityBills::Bills::Contracts::Base)

  step Contract::Validate(key: 'bill')

  step Contract::Persist()

  def skip_user_authorization!(context, options)
    true
  end

  def check_bill_presence(options, params:, **)
    autofetched = params[:autofetched]
    return true unless autofetched # User is manually creating bill; skip step

    subscription_id = params[:subscription_id]

    subscription = BbpsBillerSubscription.find_by id: subscription_id

    return false if autofetched and subscription.blank?

    bill = nil
    due_date, bill_date = params[:due_date], params[:bill_date]
    bill_month, bill_period = params[:bill_month], params[:bill_period]
    early_payment_date = DateUtils.parse_date(params[:early_payment_date])

    if (due_date.present? && due_date != "NA" && due_date != "9999-01-01") && (due_date.present? && due_date != "NA" && due_date != "0001-01-01")
      bill = subscription.bbps_bills.where("bill_date = ? AND due_date = ?", Date.parse(due_date), Date.parse(due_date)).first
    elsif due_date.present? && due_date != "NA" && due_date != "9999-01-01"
      bill = subscription.bbps_bills.where("due_date = ?", Date.parse(due_date)).first
    elsif due_date.present? && due_date != "NA" && due_date != "0000-01-01"
      bill = subscription.bbps_bills.where("bill_date = ?", Date.parse(due_date)).first
    elsif bill_month.present?
      bill = subscription.bbps_bills.where(bill_month: bill_month)
    elsif early_payment_date.present?
      bill = subscription.bbps_bills.where(early_payment_date: early_payment_date)
    elsif bill_period.present?
      # Received the following kinds of bill numbers
      # ["1", nil, "december", "march", "may", "Monthly", "JANUARY", "MONTHLY", "FEBRUARY", "0.0", "JAN 20", "202002", "DECEMBER"]
      if bill_periods.include?(bill_period&.to_s.downcase) # Deals with different months
        bill = subscription.bbps_bills.where(bill_period: bill_period).first
      elsif ["monthly"].includes?(bill_period.to_s.downcase) # Deals with "Monthly"; Also changes it to current month
        bill_period = Date.today.strftime("%b")
        bill = subscription.bbps_bills.where(bill_period: bill_period).first
      elsif bill_periods.filter {|month| period.downcase.index(month)}.present? # Deals with format 'JAN 20'
        bill_period = bill_periods.filter {|month| period.downcase.index(month)}[0]
        bill = subscription.bbps_bills.where(bill_period: bill_period).first
      else
        # None of the attributes for checking for existing bills exist in the response
        Event::EAlert::Create.(nil,
            title: "Ambiguous Bill Creation #{subscription.id} . #{bill&.id}",
            description: "Subscription: #{subscription.as_json} \n Bills: #{subscription.bbps_bills.last.as_json} \n Response: #{result.as_json["table"]}",
            subject: "Ambiguous Bill Creation #{subscription.id} . #{bill&.id}"
        )
      end
    else
      # None of the attributes for checking for existing bills exist in the response
      Event::EAlert::Create.(nil,
          title: "Ambiguous Bill Creation #{subscription.id} . #{bill&.id}",
          description: "Subscription: #{subscription.as_json} \n Bills: #{subscription.bbps_bills.last.as_json} \n Response: #{result.as_json["table"]}",
          subject: "Ambiguous Bill Creation #{subscription.id} . #{bill&.id}"
      )
    end

    if bill.present?
      bill.update(order_number: params[:ref_number], order_number_type: "BillFetch")
      return false
    end

    true
  end

  def set_default_params(options, params:, **)
    subscription = BbpsBillerSubscription.find_by id: params[:subscription_id]
    bill = subscription.attributes.slice(
        'policy_id', 'department_id', 'location_id',
        'cost_center_id', 'company_id', 'category_id',
        'tax_rate_id', 'hsn_sac', 'bbps_biller_id').merge(
        params.slice(
            :subscription_id,
            :bill_date, :bill_number, :due_date, :bill_month,
            :bill_period, :autofetched, :order_number, :order_number_type,
            :early_payment_date, :disconn_tag, :pc, :api_response
        )
    )

    # Add Amounts
    %i( amount late_payment_fee early_payment_fee ).each do |key|
      bill.merge!({"#{key.to_s}": {value: params.dig(key), currency_id: 1}}) if params.dig(key).present?
    end

    # Set bill validation
    bill['bill_validation_required'] = !bill[:autofetched]

    params['bill'] = bill.with_indifferent_access
  end

  private

  def bill_periods
    ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec", "january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"]
  end
end
