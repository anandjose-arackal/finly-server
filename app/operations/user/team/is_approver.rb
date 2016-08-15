class User::Team::IsApprover < User::Team::Base
  attr_accessor :managing_user, :report, :card_load_request, :for_user, :type, :result

  def pre_validate
    unless params[:report].present? or params[:card_load_request].present? or params[:user].present?
      errors << 'Error validating approver'
    end
    unless params[:type].present?
      errors << 'Error validating approver. Type not defined'
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
      end
      self.response = false
      return
    end
    if self.card_load_request.present?
      if process_card_load_request
        self.response = true
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
    emp = UserManagerMapping.has_manager(managing_user.id).with_user(for_user.id)
    if emp.present?
      return true
    end
    if params[:indirect_associations]
      approves_to_ids = UserManagerMapping.has_approves_to(managing_user.id).pluck(:id)
      while approves_to_ids.present?
        emp = UserManagerMapping.has_manager(approves_to_ids).with_user(for_user.id)
        if emp.present?
          return true
        end
        approves_to_ids = UserManagerMapping.has_approves_to(approves_to_ids).pluck(:id)
      end
    end
    false
  end

  def process_report
    process_request report.user, :report, report
  end

  def process_card_load_request
    process_request card_load_request.user, :card_load_request, card_load_request
  end

  def process_request(emp, symbol, obj)
    params = {type: :manager}
    params[symbol] = obj
    m = User::Team::Approver.(emp, params)
    while m.present?
      return true if m.id == managing_user.id
      params[:type] = :approves_to
      m = User::Team::Approver.(emp, params)
    end
    false
  end

end