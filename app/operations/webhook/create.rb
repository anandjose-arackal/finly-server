class Webhook::Create < Webhook::Base
  attr_accessor :web_hook

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:web_hook).present?
      add_message :error, 'Error in request'
      return
    end
  end

  def init
    param = strong_params
    param[:company_id] = user.company_id
    self.web_hook = user.web_hooks.build(param)
  end

  def validate
    unless self.web_hook.valid?
      add_message :error, self.web_hook.errors.full_messages
      return
    end
  end

  def process
    unless self.web_hook.save
      add_message :error, self.web_hook.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, 'Webhook Created'
  end

  protected
  def strong_params
    params.require(:web_hook).permit(:url, :secret, web_hook_event_mappings_attributes: [:web_hook_event_id])
  end

end