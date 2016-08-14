class User::Team::FinalFinanceManager < User::Team::Base
  attr_accessor :report, :card_load_request

  def pre_validate
    if user.blank?
      errors << 'User not found'
    end
    if params[:report].blank? and params[:card_load_request].blank?
      errors << 'Report or card load request not defined'
    end

    if params[:report].present? and params[:card_load_request].present?
      errors << 'You can only request for finance manager for either report or card load request'
    end
  end

  def init
    self.report = params[:report]
    self.card_load_request = params[:card_load_request]
  end

  def process
    params[:type] = :finance_manager
    m = User::Team::Approver.(user, params)
    while m.present?
      params[:type] = :approves_finance_to
      m = User::Team::Approver.(user, params)
    end
    self.response = m
  end

end