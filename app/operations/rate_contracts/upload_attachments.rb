class RateContracts::UploadAttachments < RateContracts::Base

  attr_accessor :artifact_params, :artifact

  def init
    id = params[:id] || params[:rate_contract_id]
    self.rate_contract = RateContract.find_by_id(id)
    self.artifact_params = artifact_params
  end

  def validate
    if rate_contract.blank?
      add_message :error, 'Rate contract not found!'
      return
    end
  end

  def process
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

  def artifact_params
    params.require(:artifact).permit(:attachment_file_name, :attachment_file_size, :attachment_content_type, :attachment_updated_at, :description, :company_id)
  end


end