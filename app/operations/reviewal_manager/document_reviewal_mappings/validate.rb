class ReviewalManager::DocumentReviewalMappings::Set < ReviewalManager::DocumentReviewalMappings::Base
  attr_accessor :document, :dlrms

  def init
    self.document = params[:reviewal_document]
    self.dlrms = document.document_level_reviewer_mappings
  end


  def process
    dlrms.each do |dlrm|
      
    end
  end

  private

  def mappings_parameters
    params.permit(:provider_name, document_reviewer_mappings: [:level_id, :reviewer_id])
  end
end