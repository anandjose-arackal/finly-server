class ReviewalManager::ReviewalChain < ReviewalManager::Base
  attr_accessor :document, :document_types, :document_class_name, :chain, :policy, :levels

  # In params
  # policy_id needs to be present
  def init
    self.document = params[:reviewal_document]
    self.chain = []
    self.document_types = ['PurchaseOrder', 'Invoice']
    policy_id = params[:policy_id]

    self.policy = ::Policy::Index.(user, params).policies.with_id(policy_id).first rescue nil
    self.policy = user.company.policies.with_application(:vp).with_id(policy_id).first rescue nil
  end

  def validate
    self.document_class_name = document.class.name

    unless document_types.include? document_class_name
      add_message :error, 'Invalid Document Provided'
      return
    end

  end

  def process
    unless self.policy.present?
      return
    end

    self.levels = self.policy.levels.with_entity_type(document_class_name).order(:level_number)

    levels.each do |level|
      mappings = level.level_reviewer_mappings.non_deleted

      selected_reviewer = document.document_level_reviewer_mappings.with_level_ids(level.id).with_policy_ids(policy.id).first
      level_data = {
          level_number: level.level_number,
          level_id: level.id,
          reviewers: mappings
      }
      if selected_reviewer.present?

        level_data[:selected_reviewer] = selected_reviewer.reviewer
      end


      chain.push(level_data)
    end
  end

  def success
    params[:chain] = self.chain
    ReviewalManager::ReviewalChain::IndexPresenter.new(user, params, messages)
  end

  class ReviewalManager::ReviewalChain::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :chain

    def init
      self.chain = params[:chain]
    end
  end
end