class ReviewalManager::DocumentReviewalMappings::Validate < ReviewalManager::DocumentReviewalMappings::Base
  attr_accessor :document, :dlrms, :policy, :violations_present

  def init
    self.document = params[:reviewal_document]
    self.dlrms = self.document.document_level_reviewer_mappings.includes(:level, :reviewer)
    self.policy = Policy.find self.document.policy_id
    self.violations_present = !!params[:violations_present]
  end


  def process
    amount = get_document_amount

    dlrms.each do |dlrm|
      level = dlrm.level
      valid_reviewer_ids = level.level_reviewer_mappings.non_deleted.with_threshold(amount).pluck(:reviewer_id)

      unless valid_reviewer_ids.include? dlrm.reviewer_id
        add_message :error, "Cannot set #{dlrm.reviewer.name} for level #{dlrm.level_number} as amount doesn't fall within threshold range of reviewer"
      end
    end
  end
end