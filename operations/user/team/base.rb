class User::Team::Base < BaseOperation
  attr_accessor :currency_id, :amount_value, :mappings, :policy_id


  class User::Team::Base::TeamPresenter < BaseOperation::BasePresenter

    attr_accessor :team

    def initialize(user, params)
      self.team = params[:team]
    end
  end


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
    elsif params[:card_load_request].present?
      load_card_load_request
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
    report = params[:report]
    if report.policy_id.present? and user.policies.with_id(report.policy_id).present?
      self.policy_id = report.policy_id
    else
      self.policy_id = nil
    end
    rds = ReportDetailService.new(report)
    self.currency_id = rds.currency
    self.amount_value = rds.total_amount
  end

  def load_card_load_request
    card_load_request = params[:card_load_request]
    if card_load_request.policy_id.present? and user.policies.with_id(card_load_request.policy_id).present?
      self.policy_id = card_load_request.policy_id
    else
      self.policy_id = nil
    end
    self.currency_id = card_load_request.amount.currency
    self.amount_value = card_load_request.amount.value
  end

end