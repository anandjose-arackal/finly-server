class MoneyRequest::Create < MoneyRequest::Base
  attr_accessor :policy_id, :for_user

  def authorized_user_types
    :employee
  end

  def init
    self.for_user = (params[:for_user] or user)
    self.policy_id = params[:policy_id]
    if policy_id.blank? and for_user.enforce_policy_enabled?
      self.policy_id = for_user.policies.non_default.first.id rescue nil
    end
  end

  def authorize
    if policy_id.present? and for_user.policies.with_id(policy_id).blank?
      add_message :error, 'User does not belong to the selected policy'
      raise_unauthorized_exception
    end
  end

  def process
    param = create_params
    param[:status_id] = MoneyRequestStatus.id_for(:open)
    param[:controlling_user] = self.for_user
    param[:controlling_user_role_id] = UserRole.id_for(:employee)
    param[:payment_mode_id] = PaymentMode.id_for(:cash)
    param[:policy_id] = self.policy_id
    # Money request can only be request through expense cards
    if for_user.cards.with_card_program(CardProgram.id_for(:expense)).present?
      param[:payment_mode_id] = PaymentMode.id_for(:card)
    end
    self.money_request = for_user.money_requests.build param
    if money_request.save
      self.money_request.tracks.create action_user: for_user,
                                       action_user_role_id: UserRole.id_for(:employee),
                                       modified_user: for_user,
                                       modified_user_role_id: param[:controlling_user_role_id],
                                       money_request_tracking_action_id: MoneyRequestTrackingAction.create_id,
                                       status_id: MoneyRequestStatus.id_for(:open)
      CustomField::SetFields.(money_request, FieldParentType.id_for(:money_request), reset_fields: true, save: true)
    else
      self.messages = money_request.errors.full_messages
    end
  end

  private
  def create_params
    return {} unless params[:money_request].present?
    params[:money_request].permit(:name, :required_by_date, :policy_id, items_attributes: [:category_id, amount_attributes: [:value, :currency_id]])
  end

end
