class Docs::UtilityBills::Subscriptions::Configs::Edit < Transactions::API

  pass Model(BbpsBillerSubscription, :find_by)
  step :init

  def init(options, params:, current_user:, model:, **)
    result = {}
    # result['types'] = ["DTH", "Cable", "Electricity", "Mobile Postpaid", "Water", "Landline Postpaid", "Broadband Prepaid", "Telephone", "Broadband Postpaid", "Mobile Prepaid", "Gas", "Mobile"]
    result['types'] = BbpsBiller.all.pluck(:biller_category_name).uniq.compact
    filter_params = {filter_role_id: [UserRole.id_for(:utility_bill_master_initiator), UserRole.id_for(:utility_bill_master_reviewer)], current_app: :vp}
    result['departments'] = Company::Departments::Index.(current_user, filter_params).policy_department_filter_mapping&.leaves
    result['locations'] = Company::Locations::Index.(current_user, filter_params).policy_location_filter_mapping&.leaves
    result['cost_centers'] = current_user.company.cost_centers.non_deleted
    result['policies'] = ::Policy::VendorPayments::Index.(current_user, (current_user.vendor_payments_admin? ? {current_app: :vp} : filter_params)).policies rescue Policy.none
    result['categories'] = current_user.company.categories.inward_invoice_items_only
    result['tax_rates'] = current_user.company.tax_rates
    result['custom_fields_config'] = custom_fields_config(current_user)

    result['reviewal_chains'] = []

    if model.present? && model.user_id.present?
      parameters = {reviewal_document: model, provider_name: 'BbpsBillerSubscriptionProvider'}
      result['policies'].each do |policy|
        parameters['policy_id'] = policy.id
        chain = {
            policy_id: policy.id,
            reviewal_chain: get_reviewal_chain(model.user, parameters)
        }

        result['reviewal_chains'].push(chain)
      end
    else
      parameters = {provider_name: 'BbpsBillerSubscriptionProvider'}
      result['policies'].each do |policy|
        parameters['policy_id'] = policy.id
        chain = {
            policy_id: policy.id,
            reviewal_chain: get_reviewal_chain(current_user, parameters)
        }

        result['reviewal_chains'].push(chain)
      end
    end

    options['result'] = result
  end


  def get_reviewal_chain(user, parameters)
    op = ::ReviewalManager::ReviewalChain.(user, parameters)
    op.chain
  end

  def custom_fields_config(current_user)
    configurations = current_user.company.field_configurations.exclude_deleted.root_fields.order_created_at_desc
    configurations.with_parent_type(FieldParentType.id_for(:BbpsBillerSubscription))
  end
end