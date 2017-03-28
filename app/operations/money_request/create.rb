class MoneyRequest::Create < MoneyRequest::Base

  def authorized_user_types
    :employee
  end

  def init

  end

  def authorize

  end

  def process
    param = create_params
    param[:status_id] = MoneyRequestStatus.id_for(:open)
    param[:controlling_user] = self.user
    param[:controlling_user_role_id] = UserRole.id_for(:employee)
    param[:payment_mode_id] = PaymentMode.id_for(:cash)
    # Money request can only be request through expense cards
    if user.cards.with_card_program(CardProgram.id_for(:expense)).present?
      param[:payment_mode_id] = PaymentMode.id_for(:card)
    end
    self.money_request = user.money_requests.build param
    if money_request.save
      self.money_request.tracks.create action_user: user,
                                       action_user_role_id: UserRole.id_for(:employee),
                                       modified_user: user,
                                       modified_user_role_id: param[:controlling_user_role_id],
                                       money_request_tracking_action_id: MoneyRequestTrackingAction.create_id,
                                       status_id: MoneyRequestStatus.id_for(:open)
      CustomField::SetMoneyRequest.(money_request, reset_fields: true, save: true)
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
