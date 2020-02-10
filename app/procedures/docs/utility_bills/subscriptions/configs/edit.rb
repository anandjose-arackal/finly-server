class Docs::UtilityBills::Subscriptions::Configs::Edit < Transactions::API

  pass Model(BbpsBillerSubscription, :find_by)
  step :init

  def init(options, params:, current_user:, model:, **)
    result = {}
    # result['types'] = ["DTH", "Cable", "Electricity", "Mobile Postpaid", "Water", "Landline Postpaid", "Broadband Prepaid", "Telephone", "Broadband Postpaid", "Mobile Prepaid", "Gas", "Mobile"]
    result['types'] = BbpsBiller.all.pluck(:biller_category_name).uniq.compact
    result['departments'] = Company::Departments::Index.(current_user, params).policy_department_filter_mapping&.leaves
    result['locations'] = Company::Locations::Index.(current_user, params).policy_location_filter_mapping&.leaves
    result['cost_centers'] = current_user.company.cost_centers.non_deleted
    result['policies'] = ::Policy::VendorPayments::Index.(current_user, {filter_role_id: [UserRole.id_for(:utility_bill_master_initiator)]}).policies rescue Policy.none
    result['categories'] = current_user.company.categories.inward_invoice_items_only
    result['tax_rates'] = current_user.company.tax_rates

    result['reviewal_chains'] = []

    if model.present?
      if model.user_id == current_user.id && BbpsBillerSubscription.status_ids(:draft, :retracted, :rejected).include?(model.status_id)
        parameters = {reviewal_document: model, provider_name: 'BbpsBillerSubscriptionProvider'}
        result['policies'].each do |policy|
          parameters['policy_id'] = policy.id
          chain = {
              policy_id: policy.id,
              reviewal_chain: get_reviewal_chain(current_user, parameters)
          }

          result['reviewal_chains'].push(chain)
        end
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
end