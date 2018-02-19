class Webhook::Destroy < Webhook::Base
  attr_accessor :web_hook

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:web_hook_id).present?
      add_message :error, 'WebHook not found'
      return
    end
  end

  def init
    self.web_hook = user.company.web_hooks.find_by(id: params[:web_hook_id])
  end

  def validate
    unless self.web_hook.present?
      add_message :error, 'Webhook not found'
      return
    end
  end

  def process
    unless self.web_hook.destroy
      add_message :error, self.web_hook.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, 'Webhook Deleted'
  end

end