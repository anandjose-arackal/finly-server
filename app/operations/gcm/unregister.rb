class Gcm::Unregister < Gcm::Base

  def process
    unless self.profile.update(gcm_sender_id: nil)
      self.messages = self.profile.errors.full_messages
    end
  end

end