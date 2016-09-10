class MoneyRequest::Comment::Create < MoneyRequest::Base

  def pre_validate
    unless params[:id].present?
      errors << 'Card request ID not found'
    end
    unless params[:content].present?
      errors << 'Nothing to post'
    end
    unless user.blank?
      errors << 'User not found'
    end
  end

  def init
    self.money_request = MoneyRequest.with_id(params[:id]).first rescue nil
  end

  def authorize
    user_id = user.id
    if money_request.blank?
      raise_unauthorized_exception
    end
    unless money_request.user_id == user_id or money_request.controlling_user_id == user_id or
        money_request.controlling_for_user_id == user_id or User::Team::IsApprover.(user, money_request: money_request, type: :manager) or
        User::Team::IsApprover.(user, money_request: money_request, type: :finance_manager)
      raise_unauthorized_exception
    end
  end

  def process

  end

end