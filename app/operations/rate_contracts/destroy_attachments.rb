class RateContracts::DestroyAttachments < RateContracts::Base
  attr_accessor :artifact

  def init
    self.artifact = Artifact.find_by_id params[:attachment_id]
  end

  def authorize
    unless artifact.present? && artifact.creator_id == user.id
      add_message :error, artifact.errors.full_messages
      return
    end
  end

  def process
    unless artifact.destroy
      add_message :error, 'Some error occurred, unable to delete'
      return
    end
  end

  def post_process
    add_message :success, 'Attachment deleted!'
  end

end