class Docs::UtilityBills::Bills::Configs::Edit < Transactions::API

  pass Model(BbpsBill, :find_by)
  step :init

  def init(options, params:, current_user:, model:, **)
    result = {}
    # result['types'] = ["DTH", "Cable", "Electricity", "Mobile Postpaid", "Water", "Landline Postpaid", "Broadband Prepaid", "Telephone", "Broadband Postpaid", "Mobile Prepaid", "Gas"]
    result['types'] = BbpsBiller.all.pluck(:biller_category_name).uniq.compact
    result['policies'] = ::Policy::VendorPayments::Index.(current_user, {filter_role_id: [UserRole.id_for(:utility_bill_initiator)]}).policies rescue Policy.none
    result['reviewal_chains'] = []

    if model.present? && model.user_id == current_user.id && BbpsBill.status_ids(:open, :retracted, :rejected).include?(model.status_id)
      parameters = {reviewal_document: model}
      parameters[:provider_name] = model.autofetched ? 'BbpsBillAutofetchedProvider' : 'BbpsBillNonAutofetchedProvider'
      result['policies'].each do |policy|
        parameters['policy_id'] = policy.id
        chain = {
            policy_id: policy.id,
            reviewal_chain: get_reviewal_chain(current_user, parameters)
        }

        result['reviewal_chains'].push(chain)
      end
    else
      parameters = {provider_name: 'BbpsBillAutofetchedProvider'}
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