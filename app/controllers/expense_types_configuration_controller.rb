class ExpenseTypesConfigurationController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

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

end
