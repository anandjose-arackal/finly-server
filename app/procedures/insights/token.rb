require 'jwt'

class Insights::Token < Transactions::API

  ANALYTICS_SITE_URL = "https://analytics.finly.io"
  ANALYTICS_SECRET_KEY = "19704626fb775091844efb44dffc284ea496b939c59fed2b04b17f595572d0f2"

  step Model(InsightDashboard, :find)
  step Policy::Pundit(Insights::Policy, :show?)
  step :parse_filters
  step :generate_token

  def parser_filters(options, params:,current_user:, **)
    filters = {
        company_id: current_user.company_id
    }

    options['filters'] = filters
    true
  end


  def generate_token(options, params:, filters:, **)
    payload = {
        :resource => {:dashboard => options['model']&.dashboard},
        :params => filters,
        :exp => Time.now.to_i + (60 * 2) # 2 minute expiration
    }

    options['token'] = JWT.encode payload, ANALYTICS_SECRET_KEY
    true
  end

end