class ReviewalManager::DocumentReviewalMappings::Set < ReviewalManager::DocumentReviewalMappings::Base
  attr_accessor :mappings_params, :document, :provider_name

  def init
    self.document = params[:reviewal_document]
    self.mappings_params = mappings_parameters
    self.provider_name = mappings_params[:provider_name] || document.get_default_provider

  end

  def validate
    unless document.present?
      add_message :error, 'Document not found'
    end

    all_level_ids = ReviewalLevel.with_policy_ids(document.policy_id).pluck(:id)

    # When document reviewer mappings present
    if mappings_params[:document_reviewer_mappings].present?
      mappings_params[:document_reviewer_mappings].each do |mapping_params|
        # check if level present in company
        level = ::ReviewalLevel.find_by id: mapping_params[:level_id]
        unless all_level_ids.include? level&.id
          add_message :error, 'Invalid Level Details'
          break
        end

        mapping_params[:level] = level
        # # check if reviewer present in company
        # todo Scope reviewers from LRM & LURM
        reviewer_ids = level.level_user_reviewer_mappings.with_user_id(user.id).pluck(:reviewer_id) + level.level_reviewer_mappings.pluck(:reviewer_id)

        if reviewer_ids.include? mapping_params[:reviewer_id]&.to_i
          reviewer = user.company.users.find_by id: mapping_params[:reviewer_id]
          mapping_params[:reviewer] = reviewer
        end
      end
    else
      # When document reviewer mappings are not present
      # Create them with current policy of the document
      if self.document.policy_id.present?
        mappings_params[:document_reviewer_mappings] = []
        self.document.policy.levels.with_entity_type(self.provider_name).each do |level|
          mapping_data = {
              level_id: level.id,
              level: level
          }
          mappings_params[:document_reviewer_mappings].push(mapping_data)
        end
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

        # If valid reviewers is empty; document level reviewr mapping will not be created for current level and will be auto approved for the current level
        next if valid_reviewers.empty?

        if level.present?
          if reviewer.present?
            if valid_reviewers.include?(reviewer.id)
              threshold = level.level_reviewer_mappings.with_reviewer_id(reviewer.id).first&.threshold
              document.document_level_reviewer_mappings.with_level_id(level.id).destroy_all
              dlrm = document.document_level_reviewer_mappings.new(
                  {
                      level_id: level.id,
                      policy_id: document.policy.id,
                      reviewer_id: reviewer.id,
                      provider_name: provider_name,
                      level_number: level.level_number,
                      threshold: threshold
                  })
              # Create new level
              dlrm.save
            else
              add_message :error, "Couldn't set #{reviewer.name} as reviewer for level #{level.level_number}, as amount is greater than threshold value"
            end
          else
            # Delete exisint dlrms
            document.document_level_reviewer_mappings.with_level_id(level.id).destroy_all

            # If reviewer overrides are present for level
            lurms = level.level_user_reviewer_mappings.with_threshold(amount)
            if lurms.present?
              lurms.each do |lurm|
                document.document_level_reviewer_mappings.create(
                    {
                        level_id: level.id,
                        level_number: level.level_number,
                        provider_name: level.associated_entity_type,
                        reviewer_id: lurm.reviewer_id,
                        policy_id: document.policy_id,
                        threshold: lurm.threshold
                    })
              end
            else
              # Overrides for users not present
              # level.reviewers.each do |level_reviewer|
              level.level_reviewer_mappings.non_deleted.each do |lrm|
                if valid_reviewers.include?(lrm.reviewer_id)
                  document.document_level_reviewer_mappings.create(
                      {
                          level_id: level.id,
                          policy_id: document.policy_id,
                          provider_name: level.associated_entity_type,
                          reviewer_id: lrm.reviewer_id,
                          level_number: level.level_number,
                          threshold: lrm.threshold
                      })
                end
              end
            end
          end
        end
      end
    end

    # find all without current policy and delete
    document.document_level_reviewer_mappings.where.not(policy_id: document.policy_id).destroy_all
  end

  private

  def mappings_parameters
    params.permit(:provider_name, document_reviewer_mappings: [:level_id, :reviewer_id])
  end
end