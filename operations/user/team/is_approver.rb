class User::Team::IsApprover < User::Team::Base
  attr_accessor :report, :card_load_request, :for_user, :type, :result

  def pre_validate
    unless params[:report].present? or params[:card_load_request].present? or params[:user].present?
      errors << 'Error validating approver'
    end
    unless params[:type].present?
      errors << 'Error validating approver. Type not defined'
    end
    unless params[:type] == :manager or params[:type] == :finance_manager
      errors << 'Error validating approver. Invalid type.'
    end
    unless user.present?
      errors << 'user not defined'
    end
  end

  def init
    self.type = params[:type]
    self.report = params[:report]
    self.card_load_request = params[:card_load_request]
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
    if self.card_load_request.present?
      if process_card_load_request
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

  private

  def process_for_user
    if self.type == :manager
      type = :has_manager
      type_approves = :has_approves_to
    else
      # type == :finance_manager
      type = :has_finance_manager
      type_approves = :has_approves_finance_to
    end
    emp = UserManagerMapping.send(type, for_user.id).with_user(for_user.id)
    if emp.present?
      return true
    end
    if params[:indirect_associations]
      approves_to_ids = UserManagerMapping.send(type_approves, for_user.id).pluck(:id)
      while approves_to_ids.present?
        emp = UserManagerMapping.send(type, approves_to_ids).with_user(for_user.id)
        if emp.present?
          return true
        end
        approves_to_ids = UserManagerMapping.send(type_approves, approves_to_ids).pluck(:id)
      end
    end
    false
  end

  def process_report
    process_request :report, report
  end

  def process_card_load_request
    process_request :card_load_request, card_load_request
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