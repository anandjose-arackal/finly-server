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

    # check if reviewer present in company
    # check if level present in company
  end

  def process
    mappings_params[:document_reviewer_mappings].each do |mapping_params|
      reviewer_id = mapping_params[:reviewer_id]
      mapping_params.delete(:reviewer_id)
      mapping = document.document_level_reviewer_mappings.find_or_initialize_by(mapping_params)

      if reviewer_id.present?
        mapping.reviewer_id = reviewer_id
        unless mapping.save
          add_message :error, "Couldn't create mapping reviewer level mapping for level_id: #{mapping_params[:level_id]}, reviewer_id: #{reviewer_id}"
        end
      else
        mapping.destroy if mapping.persisted?
      end
    end
  end

  private

  def mappings_parameters
    params.permit(document_reviewer_mappings: [:level_id, :reviewer_id])
  end
end