class Docs::UtilityBills::Subscriptions::Ops::Create < Transactions::API

  # Create an empty model
  step Model( BbpsBillerSubscription, :new )

  # Pass the model to the policy and check if user can perform the action
  step Policy::Pundit( Docs::UtilityBills::Subscriptions::Authorizer, :create? )

  # Below method makes sure all necessary data is present for contract to work properly, it also sets default value for
  # number of attributes
  step :set_default_params

  # Instantiate contract
  step Contract::Build( constant: Docs::UtilityBills::Subscriptions::Contracts::Base )

  # Validate Contract; 'key' represents under which key in params all the data can be found so it can be assigned to the
  # contract and data can be validated
  step Contract::Validate(key: 'subscription')

  # Just a method to for testing; will be removed in future
  fail :check

  # Persist saves the model if validations go through successfully
  step Contract::Persist()

  # Creates DLRMs post creation of document
  step :setup_dlrm

  # Assign roles utility bill initiator role to POC
  step :assign_poc_roles

  # Update Attachments
  step :update_attachments

  step Transactions::Messages::SuccessMessage('Utility Bill Master created successfully')

  def check(ctx, options, **)
    # ctx['result.contract.default'].errors.present?
    #
    # ctx['result.contract.default'].errors.keys.each do |key|
    #   add_message options, :error, key, ctx['result.contract.default'].errors[key]
    # end

    true
  end

  def setup_dlrm(options, current_user:, params:, model:, **)
    dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::Set.(current_user, {
        reviewal_document: model,
        document_reviewer_mappings: params[:document_reviewer_mappings]
    })

    dlrm_validation_op.success?
  end

  def set_default_params(options, params:, current_user:, **)
    bbps_biller_id = params[:bbps_biller_id] || params[:subscription][:bbps_biller_id]
    op = Docs::UtilityBills::Billers::Ops::Show.(params: {id: bbps_biller_id}, "current_user" => current_user)

    biller = op['model'] if op.success?

    params[:subscription][:user_id] = current_user&.id
    params[:subscription][:current_user] = current_user

    fetch_requirement = biller&.fetch_requirement
    support_bill_validation = biller&.support_bill_validation

    params[:subscription][:fetch_requirement] = fetch_requirement
    params[:subscription][:company_id] = current_user.company_id
    params[:subscription][:support_bill_validation] = support_bill_validation
    params[:subscription][:auto_generate_bill] = params[:subscription][:auto_generate_bill] || resolve_auto_bill_generation(fetch_requirement)
    true
  end


  def resolve_auto_bill_generation(fetch_requirement)
    case fetch_requirement
    when 'MANDATORY', 'OPTIONAL'
      true
    when 'NOT_SUPPORTED', nil
      false
    else
      false
    end
  end

  def assign_poc_roles(options, model:, params:, **)
    model.pocs.each do |poc|
      pur = PolicyUserRole.find_or_initialize_by(user_id: poc.id, policy_id: model.policy_id, user_role_id: UserRole.id_for(:utility_bill_initiator))
      pur.save
    end
    true
  end

  def update_attachments(options, model:, params:, **)
    attachments = Attachment.where(id: params[:attachment_ids])
    attachment_ids = attachments.where(resource_id: nil).or(attachments.where(resource_id: model.id, resource_type: model.class.name)).pluck(:id)

    Attachment.where(id: attachment_ids).update(resource_id: model.id, resource_type: model.class.name)
    true
  end
end