class User::Team::Base < BaseOperation
  attr_accessor :currency_id, :amount_value, :mappings, :policy_id, :money_request, :report

  def init_values
    return if params.blank?
    load_attrs
  end

  def load_attrs
    self.mappings = self.user.team_mapping.with_details
    self.currency_id = params[:currency_id]
    self.amount_value = params[:amount]
    if params[:policy_id].present? or (params[:policy].present? and params[:policy].is_a?(Integer))
      self.policy_id = (params[:policy_id] or params[:policy])
    elsif params[:policy].present?
      load_policy
    elsif params[:report].present?
      load_report
    elsif params[:money_request].present?
      load_money_request
    end
  end

  private
  def load_policy
    policy = params[:policy]
    self.policy_id = policy.id
    if params[:currency_id].present?
      self.currency_id = params[:currency_id]
    else
      self.currency_id = policy.configuration.report_currency
    end
    self.amount_value = params[:amount]
  end

  def load_report
    self.report = params[:report]
    if self.report.policy_id.present? and user.policies.with_id(report.policy_id).present?
      self.policy_id = report.policy_id
    else
      self.policy_id = nil
    end

    self.currency_id = 1 # todo - temporary, will change when currencies is implemented
    self.amount_value = self.report.total_amount
  end

  def load_money_request
    self.money_request = params[:money_request]
    if self.money_request.policy_id.present? and user.policies.with_id(money_request.policy_id).present?
      self.policy_id = money_request.policy_id
    else
      self.policy_id = nil
    end
    self.currency_id = 1
    self.amount_value = self.money_request.total_amount
  end

  class User::Team::Base::TeamPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :team
    attr_accessor :team_managers, :team_finance_managers, :team_admins

    def init
      self.team = params[:team]
    end
  end

end
