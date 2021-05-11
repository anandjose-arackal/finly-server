class FormsToggle < ApplicationToggle

  def enabled?
    feature_flag 'permissions/forms/predictions#enabled', false
  end

end