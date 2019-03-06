# File used to validate the current set of dlrms.
# Usually called before submitting, and prevents user from submitting if errors are found

class ReviewalManager::DocumentReviewalMappings::Validate < ReviewalManager::DocumentReviewalMappings::Base
  attr_accessor :document, :dlrms, :policy, :violations_present, :reviewal_levels

  def init
    self.document = params[:reviewal_document]
    self.dlrms = self.document.document_level_reviewer_mappings.includes(:level, :reviewer)
    self.policy = user.company.policies.non_deleted.find_by id: self.document.policy_id
    self.violations_present = !!params[:violations_present]

    provider_name = self.document.get_default_provider
    if self.policy.present?
      self.reviewal_levels = self.policy.levels.with_associted_entity_type(provider_name).non_deleted.reorder(:level_number)
    end
  end

  def validate
    unless self.document.present?
      add_message :error, 'Document not found'
    end
  end


  def process
    # Check
    amount = get_document_amount
    self.reviewal_levels.each do |level|
      if level.level_user_reviewer_mappings.with_user_id(user.id).with_threshold(amount).with_exception(violations_present).present?
        valid_reviewer_ids = level.level_user_reviewer_mappings.with_user_id(user.id).with_threshold(amount).with_exception(violations_present).pluck(:reviewer_id)
      else
        valid_reviewer_ids = level.level_reviewer_mappings.non_deleted.with_threshold(amount).with_exception(violations_present).pluck(:reviewer_id)
      end

      valid_reviewer_ids.compact!

      if valid_reviewer_ids.present?
        level_specific_dlrms = dlrms.with_level_id(level.id)

        if level_specific_dlrms.present?
          level_specific_dlrms.each do |dlrm|
            unless valid_reviewer_ids.include? dlrm.reviewer_id
              level_details = ['Level', level.level_number.to_s, level.name].join(" - ")
              add_message :error, "Cannot set #{dlrm.reviewer.name} for '#{level_details}' as amount doesn't fall within threshold range of reviewer"
            end
          end
        else
          add_message :error, "Changes found in document. Reviewal Flow needs to be updated"
        end
      else
        # If Valid reviewers are not present, should check if DLRM is created for it
        level_specific_dlrms = dlrms.with_level_id(level.id)

        if level_specific_dlrms.present?
          add_message :error, "Changes found in document. Reviewal Flow needs to be updated"
        end
      end
    end




    # amount = get_document_amount
    # dlrms.each do |dlrm|
    #   level = dlrm.level

    #   if level.level_user_reviewer_mappings.with_user_id(user.id).present?
    #     valid_reviewer_ids = level.level_user_reviewer_mappings.with_user_id(user.id).with_exception(violations_present).with_threshold(amount).pluck(:reviewer_id)
    #   else
    #     valid_reviewer_ids = level.level_reviewer_mappings.non_deleted.with_exception(violations_present).with_threshold(amount).pluck(:reviewer_id)
    #   end

    #   unless valid_reviewer_ids.include? dlrm.reviewer_id
    #     level_details = ['Level', dlrm.level_number.to_s, dlrm.level.name].join(" - ")
    #     add_message :error, "Cannot set #{dlrm.reviewer.name} for '#{level_details}' as amount doesn't fall within threshold range of reviewer"
    #     # add_message :error, "Cannot set #{dlrm.reviewer.name} for level #{dlrm.level_number} as amount doesn't fall within threshold range of reviewer"
    #   end
    # end
  end
end