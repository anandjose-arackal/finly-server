class ExpenseTypesConfigurationController < BaseControllers::WebBase


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
    default_url = get_default_url('vp', current_company, current_user)
    @views = YamlUtils.load_yaml_erb("#{Rails.root}/config/data/menu_data_payments.yml.erb", {current_company: current_company, current_user: current_user, default_url: default_url})
    render json: @views.as_json
  end

  def menu_data_collect
    @views = YamlUtils.load_yaml_erb("#{Rails.root}/config/data/menu_data_collect.yml.erb", {current_company: current_company, current_user: current_user})
    render json: @views.as_json
  end

  def menu_data_insights
    @views = YamlUtils.load_yaml_erb("#{Rails.root}/config/data/menu_data_insights.yml.erb", {current_company: current_company, current_user: current_user})
    render json: @views.as_json
  end

  def groups_teams
    @result = UserGroup::Index.(current_user, params)
    if @result&.success?
      @groups = @result.user_groups
      @teams = UserTeam::Index.(current_user, params)&.user_teams
    end
    respond
  end

  def expense_filters
    @result = UserGroup::Index.(current_user, params)
    if @result&.success?
      @groups = @result.user_groups
      @teams = UserTeam::Index.(current_user, params)&.user_teams
    end
    field_parent_type_ids = [FieldParentType.id_for(:manual_expense), FieldParentType.id_for(:time_expense),FieldParentType.id_for(:distance_expense),FieldParentType.id_for(:per_diem_expense),FieldParentType.id_for(:card_expense)]

    field_configuration_result = CustomField::Configuration::Index.(current_user, {filter_field_type_id: [FieldType.id_for(:drop_down)], filter_parent_type_id: field_parent_type_ids})
    if field_configuration_result.success?
      @field_configurations = field_configuration_result.field_configurations
    end
    respond
  end

  def report_filters
    @result = UserGroup::Index.(current_user, params)
    if @result&.success?
      @policies = Policy::Index.(current_user, view: params[:view])
      @groups = @result.user_groups
      @teams = UserTeam::Index.(current_user, params)&.user_teams
      @categories = current_company.categories.active rescue []
    end
    field_configuration_result = CustomField::Configuration::Index.(current_user, {filter_field_type_id: [FieldType.id_for(:drop_down)], filter_parent_type_id: [FieldParentType.id_for(:report)]})
    if field_configuration_result.success?
      @field_configurations = field_configuration_result.field_configurations
    end
    respond
  end

  def get_default_url(product, company, user)
    path = ""

    case product
      when 'vp'
        path = 'dashboard'
        if company.feature_subscription.procurement
          path = 'dashboard'
        end
      else
        path = ""
    end

    path
  end

end
