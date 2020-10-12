# Creates DLRMs for documents
# Usually called while creating/updating document

class ReviewalManager::DocumentReviewalMappings::Set < ReviewalManager::DocumentReviewalMappings::Base
  attr_accessor :mappings_params, :document, :provider_name, :reviewal_chain_data, :violations_present, :document_amount, :dlrm_mapping_data, :reviewal_levels

  def init
    self.document = params[:reviewal_document]
    self.mappings_params = mappings_parameters
    self.provider_name = params[:provider_name] || document.get_default_provider
    self.violations_present = !!params[:violations_present]
    self.reviewal_chain_data = []
    self.dlrm_mapping_data = [] # will contain dlrm_level_data inside of it
    self.document_amount = get_document_amount
    self.reviewal_levels = ReviewalLevel.with_policy_ids(document.policy_id).with_associated_entity_type(provider_name).non_deleted.reorder(:level_number) # todo - when policy id is not present
  end

  def validate
    unless document.present? && provider_name.present?
      add_message :error, 'Document not found'
      return
    end

    # Get all levels for the current policy and provider

    # For each level
    if reviewal_levels.present?
      # If reviewer selection data is provided from frontend
      if mappings_params[:document_reviewer_mappings].present?
        reviewal_levels.each do |level|

          # For each level find the reviewer selection data
          mapping_params = get_mapping_data(level)

          reviewer_id = mapping_params[:reviewer_id] if mapping_params.present?

          # If no reviewer is selected skip to next level
          # next if mapping_params.blank? || mapping_params[:reviewer_id].blank?

          # Get possible reviewers for the level | user level configuration
          # level_reviewers = level.lurms.with_user_id(user.id).with_reviewer.with_threshold(document_amount).with_exception(violations_present)
          # Picking LURMs with reviewers because if reviewer is blank its gonna be skipped anyways and default level will be set
          level_reviewers_data = level.level_user_reviewer_mappings.with_user_id(user.id).with_reviewer.as_json

          # Get possible reviewers for the level | fall back to company level
          unless level_reviewers_data.present?
            # level_reviewers = level.level_reviewer_mappings.with_threshold(document_amount).with_exception(violations_present)
            level_reviewers_data = level.level_reviewer_mappings.non_deleted.as_json
          end

          if reviewer_id.present?
            unless level_reviewers_data.map{|item| item['reviewer_id']}.include?(reviewer_id.to_i)
              reviewer = user.company.users.find_by id: mapping_params[:reviewer_id]
              add_message :error, "Cannot set #{reviewer.present? ? reviewer.name : 'selected reviewer'} for level - #{level.level_number} (#{level.name})"
              next
            end
          end

          # Get max for all reviewers
          max_thresholds = level_reviewers_data.map{|item| item['max']}
          # min_thresholds = level_reviewers_data.map{|item| item['min']}

          # If level doesn't have reviewers
          if max_thresholds.compact.present?
            if !max_thresholds.include?(nil) && document_amount > max_thresholds.compact.max.to_f
              document_class_name = document.class.human_name rescue document.model_name.human.titleize
              add_message :error, "#{document_class_name}'s amount is greater than maximum limit set in Level - #{level.level_number} (#{level.name})"
            end
          end

          # Check if selected reviewer is a valid reviewer
          valid_threshold_reviewer_data = level_reviewers_data.filter{|item| item['min'].to_f <= document_amount && (item['max'].blank? || item['max'].to_f >= document_amount )}
          valid_violation_reviewer_data = level_reviewers_data.filter do |item|
            if violations_present
              !!item['exception']
            else
              !!item['wo_exception']
            end
          end

          if reviewer_id.present?
            valid_threshold_reviewer_ids = valid_threshold_reviewer_data.map{|item| item['reviewer_id']}
            valid_violation_reviewer_ids = valid_violation_reviewer_data.map{|item| item['reviewer_id']}

            if valid_threshold_reviewer_ids.present? && !valid_threshold_reviewer_ids.include?(reviewer_id.to_i)
              reviewer = User.find_by id: mapping_params[:reviewer_id]
              add_message :error, "Cannot set #{reviewer.present? ? reviewer.name : 'selected reviewer'} for Level - #{level.level_number} (#{level.name}) | Approval Limit Mismatch"
            end

            if valid_violation_reviewer_ids.present? && !valid_violation_reviewer_ids.include?(reviewer_id.to_i)
              reviewer = User.find_by id: mapping_params[:reviewer_id]
              add_message :error, "Cannot set #{reviewer.present? ? reviewer.name : 'selected reviewer'} for Level - #{level.level_number} (#{level.name}) | Violations #{!!violations_present ? "present" : "not present"}"
            end
          end


          # if !min_thresholds.include?(0) && document_amount < min_thresholds.min
          #   add_message :error, "#{document.class.name}'s amount is less than minimum threshold set in Level - #{level.level_number} (#{level.name})"
          # end
        end
        # # If Reviewer Selection data is NOT provided from frontend
        # # Nothing is provided | create w/ default data set (LURM/LRM)
        # else
        #   reviewal_levels.each do |level|

        #   end
        # end
      end
    end
  end


  def pre_process
    # Create dlrm_mappings_data
    reviewal_levels.each do |level|
      mapping_params = get_mapping_data(level)

      dlrm_level_data = {level: level}

      # In case no reviewers are selected
      if mapping_params.blank? || mapping_params[:reviewer_id].blank?

        overrides_present = level.level_user_reviewer_mappings.with_user_id(user.id).present?

        level_reviewers_data = level.level_user_reviewer_mappings.with_user_id(user.id).
            with_threshold(document_amount).
            with_exception(violations_present).with_reviewer.as_json

        if level_reviewers_data.blank? && !overrides_present
          level_reviewers_data = level.level_reviewer_mappings.non_deleted.with_threshold(document_amount).with_exception(violations_present).as_json
        end

        dlrm_level_data[:reviewer_selected] = false
        dlrm_level_data[:level_reviewers_data] = level_reviewers_data

        self.dlrm_mapping_data.push(dlrm_level_data)
        next
      end

      # When Reviewers are selected on the frontend
      overrides_present = level.level_user_reviewer_mappings.with_user_id(user.id).present?
      level_reviewers_data = level.level_user_reviewer_mappings.with_user_id(user.id).with_threshold(document_amount).with_exception(violations_present).with_reviewer.as_json

      if level_reviewers_data.blank? && !overrides_present
        level_reviewers_data = level.level_reviewer_mappings.non_deleted.with_threshold(document_amount).with_exception(violations_present).as_json
      end

      if level_reviewers_data.map{|item| item['reviewer_id']}.include?(mapping_params[:reviewer_id].to_i)
        level_reviewer_data = level_reviewers_data.filter{|item| item['reviewer_id'] == mapping_params[:reviewer_id].to_i}
        dlrm_level_data[:reviewer_selected] = true
        dlrm_level_data[:level_reviewers_data] = level_reviewer_data
      end

      dlrm_mapping_data.push(dlrm_level_data)
    end
  end

  def process
    document.document_level_reviewer_mappings.with_provider_name(provider_name).destroy_all
    if dlrm_mapping_data.present?
      dlrm_mapping_data.each do |dlrm_level_data|
        if dlrm_level_data[:level_reviewers_data].present?

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
    else
      add_message :error, "No Reviewal Levels Could be Set"
    end
  end

  def ex_process
    document.document_level_reviewer_mappings.with_provider_name(provider_name).destroy_all

    if self.reviewal_chain_data.present?
      #if mappings_params[:document_reviewer_mappings].present?
      self.reviewal_chain_data.each do |mapping_params|
        #reviewer_id = mapping_params[:reviewer_id].to_i

        # reviewer = user.company.users.find_by id: reviewer_id

        # level = ::ReviewalLevel.find_by id: mapping_params[:level_id]

        reviewer = mapping_params[:reviewer]
        level = mapping_params[:level]

        amount = get_document_amount

        valid_reviewers = level.level_reviewer_mappings.non_deleted.with_threshold(amount).with_exception(violations_present).pluck(:reviewer_id) + level.level_user_reviewer_mappings.with_user_id(user.id).with_threshold(amount).with_exception(violations_present).pluck(:reviewer_id)
        # If valid reviewers is empty; document level reviewr mapping will not be created for current level and will be auto approved for the current level
        next if valid_reviewers.empty?

        if level.present?
          if reviewer.present?
            if valid_reviewers.include?(reviewer.id)
              # threshold = level.level_user_reviewer_mappings.with_user_id(user.id).with_reviewer_id(reviewer.id).first&.threshold || level.level_reviewer_mappings.non_deleted.with_reviewer_id(reviewer.id).first&.threshold
              lurm = level.level_user_reviewer_mappings.with_user_id(user.id).with_reviewer_id(reviewer.id).first || level.level_reviewer_mappings.non_deleted.with_reviewer_id(reviewer.id).first
              # document.document_level_reviewer_mappings.with_level_id(level.id).destroy_all
              dlrm = document.document_level_reviewer_mappings.new(
                  {
                      level_id: level.id,
                      policy_id: document.policy_id,
                      reviewer_id: reviewer.id,
                      provider_name: provider_name,
                      level_number: level.level_number,
                      min: lurm&.min,
                      max: lurm&.max
                  })
              # Create new level
              dlrm.save
            else
              add_message :error, "Couldn't set #{reviewer.name} as reviewer for level #{level.level_number}, as amount doesn't fall within set limits"
            end
          else
            # Delete exisint dlrms
            # document.document_level_reviewer_mappings.with_level_id(level.id).destroy_all

            # If reviewer overrides are present for level
            lurms = level.level_user_reviewer_mappings.with_user_id(user.id).with_exception(violations_present).with_threshold(amount)
            all_lurms = level.level_user_reviewer_mappings.with_user_id(user.id)
            if all_lurms.present?
              valid_lurms = all_lurms.with_reviewer.with_threshold(amount)
              valid_lurms.each do |lurm|
                document.document_level_reviewer_mappings.create(
                    {
                        level_id: level.id,
                        level_number: level.level_number,
                        provider_name: level.associated_entity_type,
                        reviewer_id: lurm.reviewer_id,
                        policy_id: document.policy_id,
                        threshold: lurm.threshold,
                        min: lurm.min,
                        max: lurm.max
                    })
              end
            else
              # Overrides for users not present
              # level.reviewers.each do |level_reviewer|
              level.level_reviewer_mappings.non_deleted.with_threshold(amount).with_exception(violations_present).each do |lrm|
                if valid_reviewers.include?(lrm.reviewer_id)
                  document.document_level_reviewer_mappings.create(
                      {
                          level_id: level.id,
                          policy_id: document.policy_id,
                          provider_name: level.associated_entity_type,
                          reviewer_id: lrm.reviewer_id,
                          level_number: level.level_number,
                          threshold: lrm.threshold,
                          min: lrm.min,
                          max: lrm.max
                      })
                end
              end
            end
          end
        end
      end
    end

    # find all without current policy and delete
    # document.document_level_reviewer_mappings.where.not(policy_id: document.policy_id).destroy_all
  end

  private

  def get_mapping_data(level)
    if mappings_params.present? && mappings_params[:document_reviewer_mappings].present?
      mapping_data = mappings_params[:document_reviewer_mappings].select {|data| data[:level_id].to_i == level.id}


      if mapping_data.length > 1
        add_message :error, "Please provide a single reviewer per level"
      end

      return mapping_data[0]
    else
      nil
    end
  end

  def mappings_parameters
    params.permit(:provider_name, document_reviewer_mappings: [:level_id, :reviewer_id])
  end
end
