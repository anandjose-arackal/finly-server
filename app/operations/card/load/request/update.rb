class Card::Load::Request::Update < Card::Load::Request::Base

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    if params[:id].blank?
      errors << 'Card Request not found'
    end
    if user.blank?
      errors << 'User not found'
    end
    return if has_errors?
    if params[:card_load_request].blank? or ((params[:card_load_request][:amount_attributes].blank? or
        params[:card_load_request][:amount_attributes][:value].blank?) and
        (params[:card_load_request][:note].blank?))
      errors << 'Nothing to update'
    end
  end

  def init
    requests = user.controlling_card_load_requests.with_id(params[:id])
    self.card_load_request = requests.first if requests.present?
  end

  def authorize
    if self.card_load_request.blank?
      errors << 'You cannot update this request'
      raise_unauthorized_exception
    end
  end

  def subscribe
    after_save self.card_load_request, &method(:generate_comments)
  end

  def process
    unless card_load_request.update_attributes(request_params)
      errors << request.errors.full_messages
    end
  end

  private
  def generate_comments(model)

  end

end