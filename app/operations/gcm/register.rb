class Gcm::Register < Gcm::Base

  def pre_validate
    super
    if params[:gcm_sender_id].blank?
      messages[:error] << 'GCM Sender ID cannot be blank'
    end
  end

  def process
    unless self.profile.update(gcm_sender_id: params[:gcm_sender_id])
      self.messages = self.profile.errors.full_messages
    end
  end

end