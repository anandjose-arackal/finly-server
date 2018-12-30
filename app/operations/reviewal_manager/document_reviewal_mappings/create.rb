class ReviewalManager::DocumentReviewalMappings::Create < ReviewalManager::DocumentReviewalMappings::Base
  attr_accessor :mappings_params, :document

  def init
    self.document = params[:reviewal_document]
    self.mappings_params = mappings_parameters
  end

  def validate
    unless document.present?
      add_message :error, 'Document not found'
    end

    if mappings_params[:document_reviewer_mappings].present?
      mappings_params[:document_reviewer_mappings].each do |mapping_params|
        # check if level present in company
        level = ::ReviewalLevel.find_by id: mapping_params[:level_id]
        unless level&.policy&.company_id == user.company_id
          add_message :error, 'Invalid Level Details'
          break
        end

        mapping_params[:level] = level

        # # check if reviewer present in company
        reviewer = user.company.users.find_by id: mapping_params[:reviewer_id]
        #
        if reviewer.present?
          mapping_params[:reviewer] = reviewer
        end
      end
    else
      mappings_params[:document_reviewer_mappings] = []
      document.policy.levels.each do |level|
        mapping_data = {
            level_id: level.id,
            level: level
        }
        mappings_params[:document_reviewer_mappings].push(mapping_data)
      end
    end
  end

  def process
    # find
    if mappings_params[:document_reviewer_mappings].present?
      mappings_params[:document_reviewer_mappings].each do |mapping_params|
        reviewer_id = mapping_params[:reviewer_id].to_i

        # reviewer = user.company.users.find_by id: reviewer_id

        # level = ::ReviewalLevel.find_by id: mapping_params[:level_id]

        reviewer = mapping_params[:reviewer]
        level = mapping_params[:level]

        amount = get_document_amount
        valid_reviewers = level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id)

        if level.present?
          if reviewer.present?
            if valid_reviewers.include?(reviewer.id)
              new_level = document.document_level_reviewer_mappings.new({
                                                                           level_id: level.id,
                                                                           policy_id: document.policy.id,
                                                                           reviewer_id: reviewer.id,
                                                                           level_number: level.level_number
                                                                       })
              document.document_level_reviewer_mappings.with_level_id(level.id).destroy_all
              new_level.save
            else
              add_message :error, "Couldn't set #{reviewer.name} as reviewer for level #{level.level_number}, as amount is greater than threshold value"
            end
          else
            document.document_level_reviewer_mappings.with_level_id(level.id).destroy_all
            level.reviewers.each do |level_reviewer|
              if valid_reviewers.include?(level_reviewer.id)

              document.document_level_reviewer_mappings.create({
                                                                   level_id: level.id,
                                                                   policy_id: document.policy_id,
                                                                   reviewer_id: level_reviewer.id,
                                                                   level_number: level.level_number
                                                               })
              end
            end
          end
        end

        # if level.present? && reviewer.present?
        #   amount = get_document_amount
        #   reviewer_ids = level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id)
        #
        #   unless reviewer_ids.include?(reviewer.id)
        #     add_message :error, "Couldn't set #{reviewer.name} as reviewer for level #{level.level_number}, as amount is greater than threshold value. Please select a different reviewer."
        #     break
        #   end
        # end

        # mapping_params.delete(:reviewer_id)
        # mapping_params.delete(:reviewer)
        # mapping_params.delete(:level)
        #
        # # todo-abi remove it and run script to delete all duplicates
        # mapping_params[:policy_id] = document.policy_id

        # mapping = document.document_level_reviewer_mappings.find_or_initialize_by(mapping_params)

        # if reviewer.present?
        #   mapping.reviewer_id = reviewer.id
        #   unless mapping.save
        #     add_message :error, "Couldn't create mapping reviewer level mapping for level_id: #{mapping_params[:level_id]}, reviewer_id: #{reviewer_id}"
        #   end
        # else
        #   mapping.destroy if mapping.persisted?
        # end
      end
    end

    # find all without current policy and delete
    document.document_level_reviewer_mappings.where.not(policy_id: document.policy_id).destroy_all
  end

  private

  def mappings_parameters
    params.permit(document_reviewer_mappings: [:level_id, :reviewer_id])
  end
end