class SummaryMailer::Manager::Create < SummaryMailer::Manager::Base
  attr_accessor :manager_summary_mail_config

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
    self.manager_summary_mail_config = user.manager_summary_mail_configs.new config_params
  end

  def validate
    unless self.manager_summary_mail_config.present?
      add_message :error, 'Invalid configuration details'
      return
    end
    unless self.manager_summary_mail_config.valid?
      add_message :error, self.manager_summary_mail_config.errors.full_messages
      return
    end
  end

  def process
    unless self.manager_summary_mail_config.save
      add_message :error, self.manager_summary_mail_config&.errors&.full_messages
    end
  end

  def post_process
    # if user.manager_summary_mail_configs.present? and
    #
    # end
  end

  protected
  def config_strong_params
    params.require(:config).permit(:period_id, :scheduled_day_of_month,
                                   :scheduled_day_of_week, :scheduled_time, :entity_type)
  end

end