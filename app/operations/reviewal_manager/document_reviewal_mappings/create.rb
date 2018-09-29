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

        # check if reviewer present in company
        reviewer = user.company.users.find_by id: mapping_params[:reviewer_id]

        if reviewer.present?
          mapping_params[:reviewer] = reviewer
        end
      end

    end
  end

  def process
    if mappings_params[:document_reviewer_mappings].present?
      mappings_params[:document_reviewer_mappings].each do |mapping_params|
        reviewer_id = mapping_params[:reviewer_id]

        # reviewer = user.company.users.find_by id: reviewer_id

        # level = ::ReviewalLevel.find_by id: mapping_params[:level_id]

        reviewer = mapping_params[:reviewer]
        level = mapping_params[:level]


        if level.present? && reviewer.present?
          amount = get_document_amount
          reviewer_ids = level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id)

          unless reviewer_ids.include?(reviewer.id)
            add_message :error, "Couldn't set #{reviewer.name} as reviewer for level #{level.level_number}, as amount is greater than threshold value. Please select a different reviewer."
            break
          end
        end

        mapping_params.delete(:reviewer_id)
        mapping_params.delete(:reviewer)
        mapping_params.delete(:level)

        mapping_params[:policy_id] = document.policy_id

        mapping = document.document_level_reviewer_mappings.find_or_initialize_by(mapping_params)

        if reviewer.present?
          mapping.reviewer_id = reviewer.id
          unless mapping.save
            add_message :error, "Couldn't create mapping reviewer level mapping for level_id: #{mapping_params[:level_id]}, reviewer_id: #{reviewer_id}"
          end
        else
          mapping.destroy if mapping.persisted?
        end
      end
    end
  end

  private


  def mappings_parameters
    params.permit(document_reviewer_mappings: [:level_id, :reviewer_id])
  end
end