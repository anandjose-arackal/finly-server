class RateContracts::UploadAttachments < RateContracts::Base

  def validate
    if rate_contract.blank?
      add_message :error, 'Rate contract not found!'
      return
    end
  end

  def process
    params[:company_id] = company.id
    self.artifact = rate_contract.artifacts.build(artifact_params)
  end

  def post_process
    if artifact.valid? && artifact.save
      add_message :success, 'Upload Successful'
    else
      add_message :error, artifact.errors.full_messages
      return
    end
  end

  protected
  def artifact_params
    params.permit(:attachment, :description)
  end

end