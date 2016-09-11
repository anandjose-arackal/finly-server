class MoneyRequest::Submit < MoneyRequest::Base
  attr_accessor :to_user

  def authorized_user_types
    :employee
  end

  def pre_validate
    if params[:id].blank?
      errors << 'Card not found'
    end
    if user.blank?
      errors << 'User not found'
    end
    return if has_errors?
    if params[:money_request].blank? or
        params[:money_request][:amount_attributes].blank? or
        params[:money_request][:amount_attributes][:value].blank?
      errors << 'Amount cannot be blank'
    end
  end

  def init
    self.to_user = User::Team::Review::NextReviewer.(self.money_request)
  end

  def authorize
    unless self.user.cards.with_id(params[:id]).present?
      raise_unauthorized_exception
    end
  end

  def process
    params = request_params
    params[:card_id] = self.params[:id]
    params[:status_id] = MoneyRequestStatus.processing_id
    params[:controlling_user] =  User::Team::Review::NextReviewer.(user: user, amount: params[:amount_attributes][:value],
        currency_id: params[:amount_attributes][:currency_id])
    self.money_request = user.money_requests.build(params)
    unless money_request.present?
      errors << 'Error creating request'
      return
    end
    after_create self.money_request, &method(:after_save_callback)
    if self.money_request.save
      self.money_request.tracks.create action_user: user, money_request_tracking_action_id: MoneyRequestTrackingAction.create_id,
                                           status_id: MoneyRequestStatus.open_id, user_request_role_id: UserRole.employee_id
      self.money_request.comments.create user: user, comment_action_id: MoneyRequestCommentAction.create_id
    else
      errors << self.money_request.errors.full_messages
    end
  end

  def after_save_callback(model)

  end

end