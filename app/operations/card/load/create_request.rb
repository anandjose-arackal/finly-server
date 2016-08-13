class Card::Load::CreateRequest < Card::Base

  def authorized_user_types
    :employee
  end

  def validate
    if params[:id].blank?
      errors << 'Card not found'
    end
    if user.blank?
      errors << 'User not found'
    end
    if params[:card_load_request].blank? or
        params[:card_load_request][:amount_attributes].blank? or
        params[:card_load_request][:amount_attributes][:value].blank?
      errors << 'Amount cannot be blank'
    end
  end

  def authorize
    unless self.user.cards.with_id(params[:id]).present?
      raise_unauthorized_exception
    end
  end

  def process
    params = request_params
    params[:card_id] = self.params[:id]
    request = user.card_load_requests.build(request_params)
    unless request.present?
      errors << 'Error creating request'
      return
    end
    unless request.save
      errors << request.errors.full_messages
    end
  end

end