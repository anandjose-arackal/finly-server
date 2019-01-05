class MoneyRequests::Create < MoneyRequests::Base
  attr_accessor :policy_id, :for_user, :default_policy, :mr_create_params

  # def authorized_user_types
  #   :employee
  # end

  def init
    self.for_user = (params[:for_user] or user)
    self.policy_id = params&.dig(:money_request, :policy_id)
    if policy_id.blank? and for_user.enforce_policy_enabled?
      self.policy_id = for_user.policies.non_default.first.id rescue nil
    end
    if policy_id.blank?
      self.policy_id = user.company.default_policy.id
      self.default_policy = true
    end
    self.mr_create_params = create_params
  end

  def authorize
    if policy_id.present? and (for_user.policies.with_id(policy_id).blank? and not default_policy)
      add_message :error, 'User does not belong to the selected policy'
      raise_unauthorized_exception
    end
  end

  def pre_process
    if [1, '1'].include?(mr_create_params[:payment_mode_id]) and mr_create_params[:destination_pocket_id].blank?
      mr_create_params[:destination_pocket_id] = self.for_user.user_pockets.cash_pockets_only.first.id
    end

    if [1, '1'].include?(mr_create_params[:payment_mode_id])
      pocket = for_user.user_pockets.with_id(mr_create_params[:destination_pocket_id])&.first

      mr_create_params&.dig(:items_attributes).each do |item_attr|
        item_attr[:amount_attributes][:currency_id] = pocket.base_currency_id rescue nil
      end
    end
  end

  def process
    param = mr_create_params
    param[:status_id] = MoneyRequestStatus.id_for(:open)
    param[:controlling_user] = self.for_user
    param[:controlling_user_role_id] = UserRole.id_for(:employee)
    param[:policy_id] = self.policy_id

    if mr_create_params[:payment_mode_id].blank?
      param[:payment_mode_id] = PaymentMode.id_for(:cash)
      # Money request can only be request through expense cards
      if for_user.cards.with_card_program(CardProgram.id_for(:expense)).present?
        param[:payment_mode_id] = PaymentMode.id_for(:card)
      end
    end

    if param[:items_attributes].present?
      param[:items_attributes].each do |attribute|
        if attribute[:category_id].present?
          attribute[:money_request_item_category_id] = attribute[:category_id]
          attribute[:category_id] = nil
        end
      end
    end

    self.money_request = for_user.money_requests.build param
    if self.money_request.travel_request.blank?
      money_request.skip_customizable_validation = true # As validation breaks the creation and loading money request, prevent it during creation
    end
    if money_request.save
      self.money_request.tracks.create action_user: for_user,
                                       action_user_role_id: UserRole.id_for(:employee),
                                       modified_user: for_user,
                                       modified_user_role_id: param[:controlling_user_role_id],
                                       money_request_tracking_action_id: MoneyRequestTrackingAction.create_id,
                                       status_id: MoneyRequestStatus.id_for(:open)
      CustomField::SetFields.(money_request, FieldParentType.id_for(:money_request),
          custom_fields: params[:custom_fields], reset_fields: true, save: true)

      # Create Document Level Reviewer Mapping
      # For setting level specific reviewers from reviewal chain for a document
      params[:reviewal_document] = self.money_request.reload

      document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Create.(user, params)
      unless document_reviewer_mappings_op.success?
        add_message :error, document_reviewer_mappings_op.messages[:error]
        return
      end
    else
      self.messages[:error] = money_request.errors.full_messages
    end
  end

  def post_process
    if self.money_request.travel_request.present? and TravelRequestStatus.ids_for(:open, :processing, :retracted, :rejected).include?(self.money_request.travel_request.status_id)
      self.money_request.update(status_id: MoneyRequestStatus.id_for(:pending))
    end
  end

  private

  def create_params
    return {} unless params[:money_request].present?
    params.require(:money_request).permit(:name, :required_by_date, :memo, :policy_id, :travel_request_id, :payment_mode_id, :destination_pocket_id,
                                          items_attributes: [:category_id, :money_request_item_category_id, amount_attributes: [:value, :currency_id]])
  end

end
