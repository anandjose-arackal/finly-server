class User::Team::FinalFinanceManager < User::Team::Base
  attr_accessor :report, :money_request

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
    end
    if params[:report].blank? and params[:money_request].blank?
      messages[:error] << 'Report or card load request not defined'
    end

    if params[:report].present? and params[:money_request].present?
      messages[:error] << 'You can only request for finance manager for either report or money request'
    end
  end

  def init
    self.report = params[:report]
    self.money_request = params[:money_request]
  end

  def process
    params[:type] = :finance_manager
    m = User::Team::Approver.(user, params)
    used_ids = []
    # used_ids is to prevent circular loop when User A is assigned as User B's manager, and user B is assigned as User A's manager
    while m.present? and not used_ids.include?(m.id)
      used_ids << m.id
      params[:type] = :approves_finance_to
      m = User::Team::Approver.(m, params)
    end
    self.response = m
  end

end
