class ReviewalManager::DocumentReviewalMappings::Index < ReviewalManager::DocumentReviewalMappings::Base
  attr_accessor :document_level_reviewer_mappings

  def init
    self.document_level_reviewer_mappings = DocumentLevelReviewerMapping.all
  end


end