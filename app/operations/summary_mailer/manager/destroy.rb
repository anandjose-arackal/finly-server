class SummaryMailer::Manager::Destroy < SummaryMailer::Manager::Base
  attr_accessor :config_to_destroy

  def pre_validate
    if params&.dig(:id).blank?
      add_message :error, 'Item not found'
      return
    end
  end

  def init
    result = SummaryMailer::Index.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.config_to_destroy = result.manager_summary_mail_configs.find_by_id(params[:id])
  end

  def validate
    unless self.config_to_destroy.present?
      add_message :error, 'Item not found'
      return
    end
  end

  def process
    unless self.config_to_destroy.destroy
      add_message :error, self.config_to_destroy.errors.full_messages
    end
  end

end