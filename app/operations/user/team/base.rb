class User::Team::Base < BaseOperation
  attr_accessor :admin_view, :manager_view, :finance_view, :currency_id, :amount_value, :mappings, :response, :policy_id

  def init_values
    return if params.blank?
    load_attrs
    load_views
  end

  def load_attrs
    self.mappings = self.user.team_mapping.with_details
    self.currency_id = params[:currency_id]
    self.amount_value = params[:amount]
    if params[:policy_id].present?
      self.policy_id = params[:policy_id]
    elsif params[:policy].present?
      policy = params[:policy]
      self.policy_id = policy.id
      if params[:currency_id].present?
        self.currency_id = params[:currency_id]
      else
        self.currency_id = policy.configuration.report_currency
      end
      self.amount_value = params[:amount]
    elsif params[:report].present?
      report = params[:report]
      if report.policy_id.present? and user.policies.with_id(report.policy_id).present?
        self.policy_id = report.policy_id
      else
        self.policy_id = nil
      end
      rds = ReportDetailService.new(report)
      self.currency_id = rds.currency
      self.amount_value = rds.total_amount
    elsif params[:card_load_request].present?
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

  def retrieve
    response
  end

end