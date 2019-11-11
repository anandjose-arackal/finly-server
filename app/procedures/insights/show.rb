require 'jwt'

class Insights::Show < Transactions::API

  step Model(InsightDashboard, :find_by_uuid)
  step Policy::Pundit(Insights::Policy, :show?)
  step :parse_filters
  step :generate_token

  def parse_filters(options, params:, current_user:, **)
    filters = {
        "company_id" => current_user.company_id
    }

    options['filters'] = filters
    true
  end

  def generate_token(options, params:, filters:, **)
    payload = {
        "resource" => {"dashboard" => options['model']&.dashboard},
        "params" => filters,
        "exp" => Time.now.to_i + (60 * 2) # 2 minute expiration
    }

    token = JWT.encode payload, INSIGHTS_CONFIG[:secret]
    options['result'] = {url: INSIGHTS_CONFIG[:base_url] + "/embed/dashboard/" + token + "#bordered=false&titled=false"}
    true
  end

end