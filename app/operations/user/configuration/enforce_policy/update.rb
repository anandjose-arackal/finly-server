# operation to update the enforce policy

class User::Configuration::EnforcePolicy::Update < User::Configuration::EnforcePolicy::Base

  def init
    super()
  end

  def authorize

  end

  def validate

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