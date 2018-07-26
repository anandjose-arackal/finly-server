class ReviewalManager::ReviewalChain < ReviewalManager::Base
  attr_accessor :document, :document_types, :document_class_name, :chain, :policy, :levels

  def init
    self.document = params[:reviewal_document]
    self.chain = []
    self.document_types = ['PurchaseOrder']

    self.policy = document&.policy
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

    self.levels = self.policy.levels.with_entity_type(document_class_name)

    levels.each do |level|
      mappings = level.level_reviewer_mappings

      level_data = {
          level_number: level.level_number,
          reviewers: mappings
      }

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