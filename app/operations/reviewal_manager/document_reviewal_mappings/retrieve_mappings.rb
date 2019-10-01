# Retrieves Reviewers from Levels & Level User Configurations
# Params Required:
# - document
# - level_ids #todo - populate levels from policy if level_ids are not present
#
#

class ReviewalManager::DocumentReviewalMappings::RetrieveReviewers < ReviewalManager::DocumentReviewalMappings::Base
  attr_accessor :document, :provider_name, :violations_present, :mappings, :policy, :target_user, :document_amount

  def init
    self.document = params[:reviewal_document]
    self.provider_name = params[:provider_name] || document.get_default_provider
    self.violations_present = !!params[:violations_present]
    self.level_ids = params[:level_ids].sort
    self.target_user = params[:target_user] || user
    self.mappings = []

    self.policy = params[:policy]
    if self.policy.blank?
      self.policy = user.company.policies.find_by id: self.document.policy_id
    end

    self.document_amount = get_document_amount
  end

  def validate
    unless document.present? && provider_name.present?
      add_message :error, 'Document not found'
      return
    end

    unless policy.present?
      add_message :error, 'Policy not found'
    end
  end

  def process
    level_ids.each do |level_id|
      level = policy.levels.where(associated_entity_type: provider_name).find_by id: level_id

      if level.present?
        data = {level: level.as_json}

        lurms_with_conditions = level.level_user_reviewer_mappings.where(user_id: target_user.id).with_threshold(document_amount).with_exception(violations_present)
        lurms_without_conditions = level.level_user_reviewer_mappings.where(user_id: target_user.id)
        lrms = level.level_reviewer_mappings.non_deleted.with_threshold(document_amount).with_exception(violations_present)

        if lurms_with_conditions.present?
          lurms = level.level_user_reviewer_mappings.where(user_id: target_user.id)
          data[:mappings] = lurms_with_conditions.as_json
        elsif lurms_without_conditions.present?
          data[:mappings] = lurms_without_conditions.as_json
          data[:skip] = true
        else
          data[:mappings] = lrms.as_json
        end

        self.mappings.push(data)
      end
    end
  end

  def success
    params[:reviewer_mappings] = self.mappings
    ReviewalManager::DocumentReviewalMappings::RetrieveReviewers::ReviewersPresenter.new(user, params, :messages)
  end


  class ReviewalManager::DocumentReviewalMappings::RetrieveReviewers::ReviewersPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reviewer_mappings

    def init
      self.reviewer_mappings = params[:reviewer_mappings]
    end
  end
end
