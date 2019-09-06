class ReviewalManager::DocumentReviewalMappings::SetUnaffected < ReviewalManager::DocumentReviewalMappings::Base
  attr_accessor :mappings_params, :document, :provider_name, :reviewal_chain_data, :violations_present, :document_amount, :dlrm_mapping_data, :reviewal_levels

  def init
    self.document = params[:reviewal_document]
    self.mappings_params = mappings_parameters
    self.provider_name = params[:provider_name] || document.get_default_provider
    self.violations_present = !!params[:violations_present]
    self.reviewal_chain_data = []
    self.dlrm_mapping_data = [] # will contain dlrm_level_data inside of it
    self.document_amount = get_document_amount
    self.reviewal_levels = ReviewalLevel.with_policy_ids(document.policy_id).with_associated_entity_type(provider_name).non_deleted # todo - when policy id is not present
    self.update_type = params[:update_type] || :all

    self.current_level = self.document&.level
    self.current_dlrm = self.document&.dlrms.where(level_id: current_level&.id).first resuce nil
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

      user_preferred_reviewer_ids = user_preferences.map {|item| item["reviewer_id"]}

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

      configuration_reviewer_id = level_reviewers_data.map {|item| item["reviewer_id"]}


      level_reviewers_data = level_reviewers_data.filter {|item| user_preferred_reviewer_ids.include? item["reviewer_id"] || item["reviewer_id"].blank?}


      if level_reviewers_data.blank?
        dlrm_level_data[:destroy] = true
        next
      end

      dlrm_level_data[:reviewer_selected] = false
      dlrm_level_data[:level_reviewers_data] = level_reviewers_data

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
