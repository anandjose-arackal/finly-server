# File used to validate the current set of dlrms.
# Usually called before submitting, and prevents user from submitting if errors are found

class ReviewalManager::DocumentReviewalMappings::Validate < ReviewalManager::DocumentReviewalMappings::Base
  attr_accessor :document, :dlrms, :policy

  def init
    self.document = params[:reviewal_document]
    self.dlrms = self.document.document_level_reviewer_mappings.includes(:level, :reviewer)
    self.policy = Policy.find self.document.policy_id
  end

  def validate
    unless self.document.present?
      add_message :error, 'Document not found'
    end
  end


  def process
    amount = get_document_amount
    dlrms.each do |dlrm|
      level = dlrm.level

      valid_reviewer_ids = []

      if level.lurms.with_user_id(user.id).present?
        valid_reviewer_ids += level.lurms.with_user_id(user.id).with_threshold(amount).pluck(:reviewer_id)
      else
        valid_reviewer_ids += level.level_reviewer_mappings.non_deleted.with_threshold(amount).pluck(:reviewer_id)
      end

      unless valid_reviewer_ids.include? dlrm.reviewer_id
        level_details = ['Level', dlrm.level_number.to_s, dlrm.level.name].join(" - ")
        add_message :error, "Cannot set #{dlrm.reviewer.name} for '#{level_details}' as amount doesn't fall within threshold range of reviewer"
      end
    end
  end
end