class RateContracts::RateContractLineItems::UploadAttachments < RateContracts::RateContractLineItems::Base
  attr_accessor :artifact_params, :artifact

  def init
    id = params[:id] || params[:rate_contract_line_item_id]
    self.rate_contract_line_item = RateContractLineItem.find_by_id(id)
    self.artifact_params = artifact_params
  end

  def validate
    if rate_contract_line_item.blank?
      add_message :error, 'Line item not found'
      return
    end
  end

  def process
    self.artifact = rate_contract_line_item.artifacts.build(artifact_params)
  end

  def post_process
    if artifact.valid? && artifact.save
      add_message :success, 'Upload Successful'
    end
  end
end