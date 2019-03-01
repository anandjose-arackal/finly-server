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

      if level.level_user_reviewer_mappings.with_user_id(user.id).present?
        valid_reviewer_ids = level.level_user_reviewer_mappings.with_user_id(user.id).with_threshold(amount).pluck(:reviewer_id)
      else
        valid_reviewer_ids = level.level_reviewer_mappings.non_deleted.with_threshold(amount).pluck(:reviewer_id)
      end

      unless valid_reviewer_ids.include? dlrm.reviewer_id
        level_details = ['Level', dlrm.level_number.to_s, dlrm.level.name].join(" - ")
        add_message :error, "Cannot set #{dlrm.reviewer.name} for '#{level_details}' as amount doesn't fall within threshold range of reviewer"
        # add_message :error, "Cannot set #{dlrm.reviewer.name} for level #{dlrm.level_number} as amount doesn't fall within threshold range of reviewer"
      end
    end
  end
end