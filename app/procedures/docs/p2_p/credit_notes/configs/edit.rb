class Docs::P2P::CreditNotes::Configs::Edit < Transactions::API

  pass Model(CreditNote, :find_by)
  step :init

  def init(options, params:, current_user:, model:, **)
    result = {}
    # result['departments'] = Company::Departments::Index.(current_user, params).policy_department_filter_mapping&.leaves
    # result['locations'] = Company::Locations::Index.(current_user, params).policy_location_filter_mapping&.leaves
    # result['cost_centers'] = current_user.company.cost_centers
    result['policies'] = ::Policy::VendorPayments::Index.(current_user, {filter_role_id: [UserRole.id_for(:credit_note_initiator)]}).policies rescue Policy.none
    result['credit_note_item_types'] = CreditNoteItemType.all
    result['tax_rates'] = current_user.company.tax_rates
    result['tds_rates'] = current_user.company.tds_slabs
    result['reviewal_chains'] = []

    if model.present?
      if model.user_id == current_user.id && CreditNoteStatus.ids_for(:draft, :retracted, :rejected).include?(model.status_id)
        parameters = {reviewal_document: model, provider_name: 'CreditNoteProvider'}
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
      parameters = {provider_name: 'CreditNoteProvider'}
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