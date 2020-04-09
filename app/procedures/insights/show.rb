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

    filters[:company_id] = 2 if Rails.env.uat?

    filters[:from] = params[:from] || 1.month.ago.strftime('%Y-%m-%d') if model.can_filter_date
    filters[:to] = params[:to] || Date.today.strftime('%Y-%m-%d') if model.can_filter_date
    filters[:location_id] = Masters::Locations::Resolver.new(current_user).resolve(params: {q: {id_in: params[:location_id_in]}}).pluck(:id) if model.can_filter_location
    filters[:cost_center_id] = Masters::CostCenters::Resolver.new(current_user).resolve(params: {q: {id_in: params[:cost_center_id_in]}}).pluck(:id) if model.can_filter_cost_center
    filters[:department_id] = Masters::Departments::Resolver.new(current_user).resolve(params: {q: {id_in: params[:department_id_in]}}).pluck(:id) if model.can_filter_department
    filters[:policy_id] = Masters::Policies::Resolver.new(current_user).resolve(params: {q: {id_in: params[:policy_id_in]}}).pluck(:id) if model.can_filter_policy
    filters[:category_id] = Masters::Categories::Resolver.new(current_user).resolve(params: {q: {id_in: params[:category_id_in]}}).pluck(:id) if model.can_filter_category

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