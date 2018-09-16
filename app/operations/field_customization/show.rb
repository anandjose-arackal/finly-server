class FieldCustomization::Show < BaseOperation

  attr_accessor :configurations

  def pre_validate
    return unless user_present? and params_present?
    if params&.dig(:keys).blank?
      add_message :error, 'Keys not found'
      return
    end
  end

  def init
    self.configurations = {}
    params[:keys].each do |field_configuration_key, fields|
      klass_name = FIELD_CUSTOMIZER_KEY_MAP[field_configuration_key]
      next if klass_name.blank?
      klass = Object.const_get(klass_name)
      next if klass.blank? or not klass.respond_to?(:field_configuration_for)
      configurations[field_configuration_key] = {}
      klass.customizable_options.each do |field, dummy|
        configurations[field_configuration_key][field] = klass.field_configuration_for(field, user.company)
      end
    end
  end

  def success
    params[:configurations] = configurations
    FieldCustomization::Show::SuccessPresenter.new(user,params, messages)
  end

  class FieldCustomization::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :configurations

    def init
      self.configurations = params[:configurations]
    end

  end

end