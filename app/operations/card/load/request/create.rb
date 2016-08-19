class Card::Load::Request::Create < Card::Load::Request::Base
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
    if params[:card_load_request].blank? or
        params[:card_load_request][:amount_attributes].blank? or
        params[:card_load_request][:amount_attributes][:value].blank?
      errors << 'Amount cannot be blank'
    end
  end

  def init
    self.to_user = User::Team::Review::NextReviewer.(self.card_load_request)
  end

  def authorize
    unless self.user.cards.with_id(params[:id]).present?
      raise_unauthorized_exception
    end
  end

  def process
    params = request_params
    params[:card_id] = self.params[:id]
    params[:status_id] = CardLoadRequestStatus.processing_id
    params[:controlling_user] =  User::Team::Review::NextReviewer.(user: user, amount: params[:amount_attributes][:value],
        currency_id: params[:amount_attributes][:currency_id])
    self.card_load_request = user.card_load_requests.build(params)
    unless card_load_request.present?
      errors << 'Error creating request'
      return
    end
    after_create self.card_load_request, &method(:after_save_callback)
    if self.card_load_request.save
      self.card_load_request.tracks.create action_user: user, card_load_tracking_action_id: CardLoadTrackingAction.create_id,
                                           status_id: CardLoadRequestStatus.processing_id, user_request_role_id: UserRole.employee_id
      self.card_load_request.comments.create user: user, comment_action_id: CardLoadRequestCommentAction.create_id
    else
      errors << self.card_load_request.errors.full_messages
    end
  end

  def after_save_callback(model)
    debugger
  end

end