class MoneyRequest::Create < MoneyRequest::Base

  def authorized_user_types
    :employee
  end

  def process
    param = create_params
    param[:status_id] = MoneyRequestStatus.open_id
    param[:controlling_user] = self.user
    self.money_request = user.money_requests.build param
    if money_request.save
      self.money_request.tracks.create action_user: user, money_request_tracking_action_id: MoneyRequestTrackingAction.create_id,
                                       status_id: MoneyRequestStatus.open_id, user_request_role_id: UserRole.employee_id
    else
      self.errors = money_request.errors.full_messages
    end
  end

  private
  def create_params
    params.require(:money_request).permit(:name, :required_by_date, :policy_id, items_attributes: [:category_id, amount_attributes: [:value, :currency_id]])
  end

end