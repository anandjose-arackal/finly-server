class Docs::UtilityBills::Bills::Ops::Create < Transactions::API

  step Model(BbpsBill, :new)
  # step Policy::Pundit( Docs::UtilityBills::Bills::Authorizer, :create? )
  step :set_default_params
  step Contract::Build(constant: Docs::UtilityBills::Bills::Contracts::Base)
  step Contract::Validate(key: 'bill')

  step Contract::Persist()


  def skip_user_authorization!(context, options)
    true
  end

  def set_default_params(options, params:, **)
    subscription = BbpsBillerSubscription.find_by id: params[:subscription_id]
    bill = subscription.attributes.slice('policy_id', 'department_id', 'location_id', 'cost_center_id', 'company_id', 'category_id', 'tax_rate_id', 'hsn_sac')


    autofetched = params[:autofetched]
    # if autofetched is false, bill is getting created manually
    # In such cases only amount will be filled and the following will be ignored
    #   - late_payment_fee
    #   - fixed_charge
    #   - additional_charge

    late_payment_fee = params[:late_payment_fee]&.to_f || 0
    early_payment_fee = params[:early_payment_fee]&.to_f || 0
    convenience_fee = params[:convenience_fee]&.to_f || 0
    amount = params[:amount]&.to_f || 0

    bill['bill_date'] = params[:bill_date]
    bill['bbps_biller_id'] = subscription.bbps_biller_id
    bill['bill_number'] = params[:bill_number]
    bill['due_date'] = params[:due_date]
    bill['bill_period'] = params[:bill_period]

    bill['order_number'] = params[:order_number] if params[:order_number].present?
    bill['order_number_type'] = params[:order_number_type] if params[:order_number_type].present?

    bill['category_id'] = subscription.category_id
    bill['tax_rate_id'] = subscription.tax_rate_id
    bill['hsn_sac'] = subscription.hsn_sac

    bill['subscription_id'] = subscription.id
    bill['autofetched'] = autofetched
    bill['bill_validation_required'] = !autofetched

    bill['late_payment_fee'] = {
        value: late_payment_fee,
        currency_id: 1
    }

    bill['convenience_fee'] = {
        value: convenience_fee,
        currency_id: 1
    }

    bill['early_payment_fee'] = {
        value: early_payment_fee,
        currency_id: 1
    }

    bill['amount'] = {
        value: amount,
        currency_id: 1
    }

    params['bill'] = bill
  end
end
