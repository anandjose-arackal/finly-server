class User::Team::IsApprover < User::Team::Base
  attr_accessor :report, :money_request, :for_user, :type, :result

  def pre_validate
    unless params[:report].present? or params[:money_request].present? or params[:user].present?
      messages[:error] << 'Error validating approver'
    end
    unless params[:type].present?
      messages[:error] << 'Error validating approver. Type not defined'
    end
    unless params[:type] == :manager or params[:type] == :finance_manager
      messages[:error] << 'Error validating approver. Invalid type.'
    end
    unless user.present?
      messages[:error] << 'user not defined'
    end
  end

  def init
    self.type = params[:type]
    self.report = params[:report]
    self.money_request = params[:money_request]
    self.for_user = params[:user]
  end

  def process
    if self.report.present?
      if process_report
        self.response = true
        return
      end
      self.response = false
      return
    end
    if self.money_request.present?
      if process_money_request
        self.response = true
        return
      end
      self.response = false
      return
    end
    if self.for_user.present?
      if process_for_user
        self.response = true
      end
      self.response = false
      return
    end
    self.response = false
  end

  def retrieve
    self.response
  end

  private

  def process_for_user
    if self.type == :manager
      type = :has_manager
    else
      type = :has_finance_manager
    end
    emp = UserManagerMapping.send(type, for_user.id).with_user(for_user.id)
    if emp.present?
      return true
    end
    false
  end

  def process_report
    process_request :report, report
  end

  def process_money_request
    process_request :money_request, money_request
  end

  def process_request(symbol, obj)
    for_user = obj.user
    params = {type: self.type}
    params[symbol] = obj
    m = User::Team::Approver.(for_user, params)
    while m.present?
      if m.id == self.user.id
        return true
      end
      if self.type == :manager
        params[:type] = :approves_to
      else
        # type = :finance_manager
        params[:type] = :approves_finance_to
      end
      m = User::Team::Approver.(m, params)
    end
    false
  end

end