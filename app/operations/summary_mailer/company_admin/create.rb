class SummaryMailer::CompanyAdmin::Create < SummaryMailer::CompanyAdmin::Base
  attr_accessor :admin_summary_mail_config

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank?
      add_message :error, 'Configuration cannot be empty'
      return
    end
  end

  def init
    config_params = config_strong_params
    config_params[:application] = current_app
    self.admin_summary_mail_config = user.admin_summary_mail_configs.new config_params
  end

  def validate
    unless self.admin_summary_mail_config.present?
      add_message :error, 'Invalid configuration details'
      return
    end
    unless self.admin_summary_mail_config.valid?
      add_message :error, self.admin_summary_mail_config.errors.full_messages
      return
    end
  end

  def process
    self.admin_summary_mail_config.save
  end

  protected
  def config_strong_params
    params.require(:config).permit(:period_id, :scheduled_day_of_month,
                                   :scheduled_day_of_week, :scheduled_time)
  end

end