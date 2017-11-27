class Integrations::Tally::SetConfiguration <  Integrations::Tally::Base
  attr_accessor :tally_configuration

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:tally_configuration, :company_name).blank?
      add_message :error, 'Company name as per your Tally Account cannot be blank'
      return
    end
  end

  def init
    update_params = strong_params
    update_params[:active] = !!update_params[:active]
    self.tally_configuration = current_company.tally_configuration
    if self.tally_configuration.nil?
      self.tally_configuration = current_company.build_tally_configuration(update_params)
    else
      self.tally_configuration.assign_attributes(update_params)
    end
  end

  def validate
    if self.tally_configuration.blank?
      add_message :error, 'Error loading configuration'
      return
    end
    unless self.tally_configuration.valid?
      add_message :error, self.tally_configuration.errors.full_messages
      return
    end
  end

  def process
    self.tally_configuration.save
  end

  protected
  def strong_params
    params.require(:tally_configuration).permit(:company_name, :active)
  end

end