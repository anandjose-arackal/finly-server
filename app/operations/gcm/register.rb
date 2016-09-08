class Gcm::Register < Gcm::Base

  def pre_validate
    super
    if params[:gcm_sender_id].blank?
      errors << 'GCM Sender ID cannot be blank'
    end
  end

  def process
    unless self.profile.update(gcm_sender_id: params[:gcm_sender_id])
      self.errors = self.profile.errors.full_messages
    end
  end

end