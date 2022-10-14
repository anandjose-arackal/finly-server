class CustomFieldsController < BaseControllers::WebBase

  after_action :invalidate_caches,
               only: [:create, :update, :destroy,
                      :dropdownitem_create, :dropdownitem_destroy],
               if: -> { EmFieldConfigCacheToggle.new(current_user).enabled? }

  def invalidate_caches
    ExpenseTypeFieldConfigCacheRefreshJob.perform_later current_user.company.id, current_user.id
    EmCustomFieldIndexCache.new(current_user, nil).invalidate_instances true, false
  end

  def invalidate_show_cache(id)
    if EmFieldConfigCacheToggle.new(current_user).enabled?
      EmCustomFieldShowCache.new(current_user, id).invalidate
    end
  end

  def create
    @result = CustomField::Configuration::Create.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  def index
    unless EmFieldConfigCacheToggle.new(current_user).enabled?
      @result = CustomField::Configuration::Index.(current_user, params)
      respond

      return
    end

    custom_cache = EmCustomFieldIndexCache.new current_user, params_cache_key(params)
    through_cache custom_cache do
      @result = CustomField::Configuration::Index.(current_user, params)
      respond

      render
    end
  end

  def show
    unless EmFieldConfigCacheToggle.new(current_user).enabled?
      @result = CustomField::Configuration::Show.(current_user, params)
      respond

      return
    end

    id = (params[:id] or params[:field_configuration_id])
    custom_cache = EmCustomFieldShowCache.new current_user, id
    through_cache custom_cache do
      @result = CustomField::Configuration::Show.(current_user, params)
      respond

      render
    end
  end

  def update
    invalidate_show_cache params[:id]

    @result = CustomField::Configuration::Update.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  def destroy
    invalidate_show_cache params[:id]

    @result = CustomField::Configuration::Destroy.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  def dropdownitem_create
    invalidate_show_cache params[:field_configuration_id]

    @result = CustomField::Configuration::DropDownItem::Add.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  def dropdownitem_destroy
    invalidate_show_cache params[:field_configuration_id]

    @result = CustomField::Configuration::DropDownItem::Remove.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  def dependent_custom_fields
    @result = CustomField::FieldConfigurations::DependentIndex.(current_user, params)
    respond
  end

end
