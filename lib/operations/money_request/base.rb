class MoneyRequest::Base < Card::Base
  attr_accessor :money_request

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
    end
  end

  def init
    id = (params[:id] or params[:money_request_id])
    self.money_request = MoneyRequest::Index.(user, params).money_requests.with_id(id).first rescue nil
  end

  def authorize
    unless money_request
      raise_unauthorized_exception
    end
  end

  def success
    params[:money_request] = self.money_request
    MoneyRequest::Presenter.new(user, params, messages)
  end

  def user_role_for_money_request
    if user.id == report.user.id
      UserRole.employee_id
    elsif user.manager? and User::Team::IsApprover.(user, {money_request: self.money_request, type: :manager})
      UserRole.manager_id
    elsif user.finance_manager? and User::Team::IsApprover.(user, {money_request: self.money_request, type: :finance_manager})
      UserRole.finance_manager_id
    end
  end

  class MoneyRequest::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :money_request

    def init
      self.money_request = params[:money_request]
    end
  end

end