class Docs::UtilityBills::Bills::Configs::Edit < Transactions::API

  pass Model(BbpsBill, :find_by)
  step :init

  def init(options, params:, current_user:, model:, **)
    result = {}
    # result['types'] = ["DTH", "Cable", "Electricity", "Mobile Postpaid", "Water", "Landline Postpaid", "Broadband Prepaid", "Telephone", "Broadband Postpaid", "Mobile Prepaid", "Gas"]
    result['types'] = BbpsBiller.all.pluck(:biller_category_name).uniq.compact
    result['policies'] = ::Policy::VendorPayments::Index.(current_user, {filter_role_id: [UserRole.id_for(:utility_bill_initiator)]}).policies rescue Policy.none
    result['reviewal_chains'] = []
    result['custom_fields_config'] = custom_fields_config(current_user)

    if model.present? && model.user_id.present?
      parameters = {reviewal_document: model}
      parameters[:provider_name] = model.autofetched ? 'BbpsBillAutofetchedProvider' : 'BbpsBillNonAutofetchedProvider'
      result['policies'].each do |policy|
        parameters['policy_id'] = policy.id
        chain = {
            policy_id: policy.id,
            reviewal_chain: get_reviewal_chain(model.user, parameters)
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

  def custom_fields_config(current_user)
    configurations = current_user.company.field_configurations.exclude_deleted.root_fields.order_created_at_desc
    configurations.with_parent_type(FieldParentType.id_for(:purchase_request))
  end
end