# Ideal System
# OP : Find reviewers for passed levels for a document
#
# OP : Set


class ReviewalManager::DocumentReviewalMappings::SetUnaffected < ReviewalManager::DocumentReviewalMappings::Base
  attr_accessor :mappings_params, :document, :provider_name,
                :reviewal_chain_data, :violations_present, :document_amount, :dlrm_mapping_data,
                :reviewal_levels, :current_level, :current_dlrm

  def init
    self.document = params[:reviewal_document]
    # self.mappings_params = mappings_parameters
    self.provider_name = params[:provider_name] || document.get_default_provider
    self.violations_present = !!params[:violations_present]
    self.reviewal_chain_data = []
    self.dlrm_mapping_data = [] # will contain dlrm_level_data inside of it
    self.document_amount = get_document_amount
    self.reviewal_levels = ReviewalLevel.with_policy_ids(document.policy_id).with_associated_entity_type(provider_name).non_deleted # todo - when policy id is not present
    # self.update_type = params[:update_type] || :all

    self.current_level = self.document&.level
    self.current_dlrm = self.document&.dlrms.where(level_id: current_level&.id).first rescue nil
  end

  def validate
    unless document.present? && provider_name.present?
      add_message :error, 'Document not found'
      return
    end

    unless current_level.present?
      add_message :error, 'Current level is not defined'
      return
    end

    unless current_dlrm.present?
      add_message :error, 'Current DLRMs not defined'
      return
    end
  end

  def pre_process
    unaffected_dlrms = document.dlrms.where("level_number > ?", current_dlrm.level_number).as_json

    unaffected_reviewal_level_ids = unaffected_dlrms.map {|item| item["level_id"]}
    # Create dlrm_mappings_data
    self.reviewal_levels = self.reviewal_levels.where(id: unaffected_reviewal_level_ids)
    self.reviewal_levels.each do |level|
      # Get preferences of what was previously stored in dlrms
      user_preference_dlrms = unaffected_dlrms.filter {|item| item["level_id"] == level.id}

      user_preferred_reviewer_ids = user_preference_dlrms.map {|item| item["reviewer_id"]}

      dlrm_level_data = {level: level}

      # get reviewer from dlrm
      # get reviewers with new amount & validations
      # if reviewers match
      #   don't do shit
      # else
      #   create dlrm with new reviewer
      # end
      #
      #

      # todo handle LURM
      overrides_present = level.level_user_reviewer_mappings.with_user_id(user.id).present?

      level_reviewers_data = level.level_user_reviewer_mappings.with_user_id(user.id).
          with_threshold(document_amount).
          with_exception(violations_present).with_reviewer.as_json

      if level_reviewers_data.blank? && !overrides_present
        level_reviewers_data = level.level_reviewer_mappings.non_deleted.with_threshold(document_amount).with_exception(violations_present).as_json
      end


      # if level_reviewers_data is blank
      # delete dlrm
      # else
      #   if current dlrm falls within level_reviewers_data
      #     select all in level_reviewer_data
      #   else
      #     select intersection
      #   end
      # end
      #
      if level_reviewers_data.blank?
        dlrm_level_data[:destroy] = true
        next
      else
        intersectioned_level_reviewers_data = level_reviewers_data.filter {|item| user_preferred_reviewer_ids.include? item["reviewer_id"] || item["reviewer_id"].blank?}


        if intersectioned_level_reviewers_data.present?
          dlrm_level_data[:level_reviewers_data] = intersectioned_level_reviewers_data
        else
          dlrm_level_data[:level_reviewers_data] = level_reviewers_data
        end
      end

      # dlrm_level_data[:reviewer_selected] = false
      # dlrm_level_data[:level_reviewers_data] = level_reviewers_data

      self.dlrm_mapping_data.push(dlrm_level_data)
    end
  end

  def process
    if dlrm_mapping_data.present?
      dlrm_mapping_data.each do |dlrm_level_data|
        if dlrm_level_data[:level_reviewers_data].present?

          if dlrm_level_data[:destroy]
            document.document_level_reviewer_mappings.where(level_id: dlrm_level_data[:level]&.id).destroy_all
            next
          end

          document.document_level_reviewer_mappings.where(level_id: dlrm_level_data[:level]&.id).destroy_all

          dlrm_level_data[:level_reviewers_data].each do |level_reviewer_data|
            dlrm = document.document_level_reviewer_mappings.new({
                                                                     level_id: dlrm_level_data[:level].id,
                                                                     level_number: dlrm_level_data[:level].level_number,
                                                                     policy_id: document.policy_id,
                                                                     reviewer_id: level_reviewer_data['reviewer_id'],
                                                                     provider_name: provider_name,
                                                                     min: level_reviewer_data['min'],
                                                                     max: level_reviewer_data['max']
                                                                 })
            # Create new level
            dlrm.save
          end
        end
      end
    end

  end

  private

  def mappings_parameters
    params.permit(:provider_name, document_reviewer_mappings: [:level_id, :reviewer_id])
  end
end
