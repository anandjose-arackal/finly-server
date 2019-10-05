# Ideal System
# OP : Find reviewers for passed levels for a document
#
# OP : Set


class ReviewalManager::DocumentReviewalMappings::SetUnaffected < ReviewalManager::DocumentReviewalMappings::Base
  attr_accessor :mappings_params, :document, :provider_name, :policy,
                :violations_present, :document_amount,
                :current_level, :current_dlrm, :unaffected_dlrms, :reviewer_mappings

  def init
    self.document = params[:reviewal_document]
    self.provider_name = params[:provider_name] || document.get_default_provider
    self.violations_present = !!params[:violations_present]
    self.document_amount = get_document_amount
    self.policy = user.company.policies.where(id: document.policy_id).first

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

    unless policy.present?
      add_message :error, "Policy not found"
    end
  end

  def pre_process
    unaffected_levels = self.policy.levels.with_associated_entity_type(provider_name).where("level_number > ?",current_level.level_number).pluck(:id)
    self.unaffected_dlrms = document.dlrms.where("level_number > ?", current_dlrm.level_number).as_json

    reviewer_mapping_op = ReviewalManager::DocumentReviewalMappings::RetrieveMappings.(user, {
      reviewal_document: document,
      violations_present: violations_present,
      level_ids: unaffected_levels,
      target_user_id: document.document_owner_id,
    })

    if reviewer_mapping_op.success?
      self.reviewer_mappings = reviewer_mapping_op.reviewer_mappings
    else
      add_message :error, reviewer_mapping_op.messages[:error]
      return
    end

    # reviewer mappings should have all the reviewers
    reviewer_mappings.each do |reviewer_mapping|
      next if reviewer_mapping[:skip]

      user_preferred_dlrms = unaffected_dlrms.filter {|item| item["level_id"]&.to_i == reviewer_mapping["level_id"]&.to_i}
      user_preferred_reviewer_ids = user_preferred_dlrms.map{|item| item["reviewer_id"]}

      preferred_mappings = reviewer_mapping[:mappings].filter {|item| user_preferred_reviewer_ids.include? item["reviewer_id"].to_i}


      # When user preferred reviewers are present with valid reviewers
      if preferred_mappings.present?
        reviewer_mapping[:mappings] = preferred_mappings
      end
    end
  end

  def process
    reviewer_mappings.each do |reviewer_mapping|
      document.document_level_reviewer_mappings.where(level_id: reviewer_mapping[:level_id]).destroy_all

      # Skip creation
      next if reviewer_mapping[:skip]

      document.document_level_reviewer_mappings.where(level_id: reviewer_mapping[:level_id]).destroy_all

      reviewer_mapping[:mappings].each do |mappings|
        dlrm = document.document_level_reviewer_mappings.new({
                                                                 level_id: reviewer_mapping[:level]["id"],
                                                                 level_number: reviewer_mapping[:level]["level_number"],
                                                                 policy_id: document.policy_id,
                                                                 reviewer_id: mappings['reviewer_id'],
                                                                 provider_name: provider_name,
                                                                 min: mappings['min'],
                                                                 max: mappings['max']
                                                             })

        dlrm.save
      end
    end
  end
end
