class MoneyRequest::Destroy < MoneyRequest::Base

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'User or params not passed.'
    end
  end

  def validate
    # check if the report can be destroyed at all
    unless report.can_destroy?
      messages[:error] << "Report can only be deleted once it's retracted or rejected"
    end
  end

  def authorize
    super
    unless money_request.user_id == user.id
      raise_unauthorized_exception
    end
  end

  def process
    unless money_request.destroy
      messages[:error] << money_request.errors.full_messages
    end
  end

  def post_process
    messages[:success] = 'Money Request destroyed'
  end

end