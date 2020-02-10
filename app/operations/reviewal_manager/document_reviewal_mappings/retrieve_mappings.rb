# Retrieves Reviewers from Levels & Level User Configurations
# Params Required:
# - document
# - level_ids #todo - populate levels from policy if level_ids are not present
#
#

class ReviewalManager::DocumentReviewalMappings::RetrieveMappings < ReviewalManager::DocumentReviewalMappings::Base
  attr_accessor :document, :provider_name, :violations_present, :level_ids,
                :mappings, :policy, :target_user_id, :document_amount

  def init
    self.document = params[:reviewal_document]
    self.provider_name = params[:provider_name] || document.get_default_provider
    self.violations_present = !!params[:violations_present]
    self.level_ids = params[:level_ids].sort
    self.target_user_id = params[:target_user_id] || user.id
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
        data = {level: level.as_json, skip: false, level_id: level.id}

        lurms = level.level_user_reviewer_mappings.where(user_id: target_user_id).as_json

        if lurms.present?
          lurms_wo_reviewer = lurms.filter {|item| item["reviewer_id"].blank? }

          if lurms_wo_reviewer.present?
            data[:skip] = true
          else
            lurms_w_conditions = lurms.filter do |item|
              if violations_present
                (item["min"] <= document_amount) && (item["max"].blank? || item["max"] >= document_amount) && item["exception"]
              else
                (item["min"] <= document_amount) && (item["max"].blank? || item["max"] >= document_amount) && item["wo_exception"]
              end
            end
            if lurms_w_conditions.present?
              data[:mappings] = lurms_w_conditions
            else
              data[:skip] = true
            end
          end
        else
          lrms = level.level_reviewer_mappings.non_deleted.with_threshold(document_amount).with_exception(violations_present).as_json
          if lrms.present?
            data[:mappings] = lrms
          else
            data[:skip] = true
          end
        end


        self.mappings.push(data)
      end
    end
  end

  def success
    params[:reviewer_mappings] = self.mappings
    ReviewalManager::DocumentReviewalMappings::RetrieveMappings::MappingsPresenter.new(user, params, :messages)
  end


  class ReviewalManager::DocumentReviewalMappings::RetrieveMappings::MappingsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reviewer_mappings

    def init
      self.reviewer_mappings = params[:reviewer_mappings]
    end
  end
end
