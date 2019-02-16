class MoneyRequests::Destroy < MoneyRequests::Base
  attr_accessor :money_requests

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'User or params not passed.'
    end
    if params.blank?
      add_message :error, 'Money Request not found'
    end
  end

  def init
    id = (params[:id] or params[:money_request_id])
    self.money_requests = MoneyRequests::Index.(user, params).money_requests.with_id(id)
  end

  def validate
    unless self.money_requests.present?
      add_message :error, 'Nothing to delete'
      return
    end
    if self.money_requests.without_user(user.id).present?
      add_message :error, "The list contains items that cannot be deleted"
      return
    end
    # check if the report can be destroyed at all
    self.money_requests.each do |money_request|
      unless money_request.can_destroy?
        add_message :error, "Money Request can only be deleted once it's retracted or rejected."
        return
      end
    end
  end

  def authorize
  end

  def process
    self.money_requests.each do |money_request|
      unless money_request.destroy
        messages[:error] = money_request.errors.full_messages
      end
    end
  end

  def post_process
    messages[:success] << 'Money Request deleted'
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end

end
