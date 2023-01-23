class FormsState < ApplicationToggle
  def form_configurations(config_value = '')
    feature_value config_value, false
  end
  def feature_enabled?(config = '')
    feature_flag config, false
  end
end
