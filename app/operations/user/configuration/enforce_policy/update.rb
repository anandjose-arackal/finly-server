# operation to update the enforce policy

class User::Configuration::EnforcePolicy::Update < User::Configuration::EnforcePolicy::Base

  def init
    super()
  end

  def authorize

  end

  def validate
    if selected_user.policies.non_default.count == 0
      add_message :error, "#{selected_user.name} needs to be part of at least one non-default policy to enable this configuration"
    end
  end

  def process
    unless enforce_config.update_attributes(update_params)
      add_message :error, enforce_config.errors.full_messages
    end
  end

  private

  def update_params
    params.require(:enforce_policy).permit(:enabled)
  end

end