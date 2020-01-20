require 'jwt'

class Insights::Show < Transactions::API

  step Model(InsightDashboard, :find_by_uuid)
  step Policy::Pundit(Insights::Policy, :show?)
  step :parse_filters
  step :generate_token
  step :set_filters

  def parse_filters(options, params:, current_user:, model:, **)
    filters = {}

    filters[:company_id] = current_user.company_id
    filters[:from] = params[:from] || 1.month.ago.strftime('%Y-%m-%d') if model.can_filter_from
    filters[:to] = params[:to] || Date.today.strftime('%Y-%m-%d') if model.can_filter_to

    options['filters'] = filters
    true
  end


  def generate_token(options, params:, filters:, model:, **)
    payload = {
        :resource => {:dashboard => model&.dashboard},
        :params => filters,
        :exp => Time.now.to_i + (60 * 10) # 2 minute expiration
    }

    insights_config = Rails.application.config_for(:insights_config)&.with_indifferent_access

    token = JWT.encode payload, insights_config[:secret]
    options['result'] = {url: insights_config[:base_url] + "/embed/dashboard/" + token + "#bordered=false&titled=false"}
    true
  end

  def set_filters(options, model:, **)
    options['result'][:filters] = model.filter_config
    true
  end

end