class ReviewalManager::DocumentReviewalMappings::Create < ReviewalManager::DocumentReviewalMappings::Base
  attr_accessor :mappings_params, :document

  def init
    self.document = params[:reviewal_document]
    self.mappings_params = mappings_parameters
  end

  def validate
    unless document.present?
      add_message :error, 'Docuemnt not found'
    end

    # check if reviewer present in company
    # check if level present in company
  end

  def process
    mappings_params[:document_reviewer_mappings].each do |mapping_params|
      mapping_params[:policy_id] = document.policy_id
      mapping = document.document_level_reviewer_mappings.find_or_initialize_by(mapping_params[:level_id])
      mapping.reviewer_id = mapping_params[:reviewer_id]
      unless mapping.save
        add_message :error, "Couldn't create mapping reviewer level mapping for level_id: #{mapping_params[:level_id]}, reviewer_id: #{mapping_params[:reviewer_id]}"
      end
    end
  end

  private

  def mappings_parameters
    params.permit(document_reviewer_mappings: [:level_id, :reviewer_id])
  end
end