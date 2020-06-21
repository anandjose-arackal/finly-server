class Docs::UtilityBills::Bills::Ops::Create < Transactions::API

  step Model(BbpsBill, :new)

  # step Policy::Pundit( Docs::UtilityBills::Bills::Authorizer, :create? )

  step :check_bill_presence

  step :set_default_params

  step Contract::Build(constant: Docs::UtilityBills::Bills::Contracts::Base)

  step Contract::Validate(key: 'bill')

  step Contract::Persist()

  step :expire_old_bills

  step :update_subscription

  # fail :update_subscription

  # add method

  def skip_user_authorization!(context, options)
    true
  end

  def check_bill_presence(options, params:, **)
    autofetched = params[:autofetched]
    return true unless autofetched # User is manually creating bill; skip step

    subscription_id = params[:subscription_id]

    subscription = BbpsBillerSubscription.find_by id: subscription_id

    options[:subscription] = subscription

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
      bill.merge!({"#{key.to_s}": {value: (params.dig(key) || 0), currency_id: 1}})
    end

    bill[:api_response][0].merge({fetch_type: 'AutoFetch'}) if bill[:api_response].is_a?(Array) && bill[:api_response][0].present?

    # Set bill validation
    bill['bill_validation_required'] = !bill[:autofetched]

    params['bill'] = bill.with_indifferent_access
  end

  def expire_old_bills(options, params:, **)

    subscription = BbpsBillerSubscription.find_by id: params[:subscription_id]
    # find_old bills for the subscription
    status_ids = BbpsBill.status_ids(:open, :awaiting_approval, :approved, :auto_approved, :payment_ticket_created )
    bills = subscription.bbps_bills.where(status_id: status_ids).where.not(order_number: params[:order_number])
    if bills.count > 0
      bills.each do |bill|
        # update status and add error
        bill.errors.add(:error, 'This bill is expired' )
        bill.payments.each do |payment|
          payment.system_messages.create({
                                             content: 'Bill expired',
                                             system_message_type_id: SystemMessageType.id_for(:error)
                                         })
        end
        bill.update(status_id: BbpsBillStatus.id_for(:expired))
        bill.payments.update_all(payment_status_id: PaymentStatus.id_for(:failed))
      end
    end
    true
  end

  def update_subscription(options, params:, subscription:, model:, **)
    update_params = {
        refreshed_at: model.generated_at,
        biler_response: nil
    }
    update_params[:last_bill_generated_at] = model.generated_at if model.present?
    update_params[:last_bill_due_date] = model.due_date if model.present? and model.due_date.present? and model.due_date.to_s != "9999-01-01"
    update_params[:last_bill_bill_date] = model.bill_date if model.present? and model.bill_date.present? and model.bill_date.to_s != "0000-01-01"

    subscription.update(update_params)
  end

  private

  def bill_periods
    ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec", "january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"]
  end
end
