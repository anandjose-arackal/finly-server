class ExpenseTypesConfigurationController < ApplicationController


  before_action -> { finly_authorize! :web}

  def show
    @result = ExpenseTypes::Show.(current_user, params)
    respond
  end

  def update
    case params[:type]
      when '1'
        @result = ExpenseTypes::ExDistanceConfig::Update.(current_user, params)
      when '2'
        @result = ExpenseTypes::ExTimeConfig::Update.(current_user, params)
      when '3'
        @result = ExpenseTypes::ExPerDiemConfig::Update.(current_user, params)
      else
        # do nothing
    end
    respond
  end

  def index

  end

  def menu_data_cards
    @views = YamlUtils.load_yaml_erb("#{Rails.root}/config/data/menu_data_cards.yml.erb", {current_company: current_company, current_user: current_user})
    render json: @views.as_json
  end

  def menu_data_disburse
    @views = YamlUtils.load_yaml_erb("#{Rails.root}/config/data/menu_data_disburse.yml.erb", {current_company: current_company, current_user: current_user})
    render json: @views.as_json
  end

  def features_subscribed
    @views = YamlUtils.load_yaml_erb("#{Rails.root}/config/data/feature_subscription.yml.erb", {current_company: current_company, current_user: current_user})
    render json: @views.as_json
  end

  def menu_data_payments
    @views = YamlUtils.load_yaml_erb("#{Rails.root}/config/data/menu_data_payments.yml.erb", {current_company: current_company, current_user: current_user})
    render json: @views.as_json
  end

end
