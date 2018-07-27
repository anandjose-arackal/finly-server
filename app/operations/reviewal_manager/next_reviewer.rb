class ReviewalManager::NextReviewers < ReviewalManager::Base
  attr_accessor :document, :document_types, :document_class_name, :next_reviewer, :policy, :levels

  def init
    self.document = params[:reviewal_document]
    self.next_reviewer = nil
    self.next_level = nil
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

    current_level = ReviewalLevel.with_id(document_order.controlling_level_id).first
    level_number = current_level.present? ? (current_level.level_number + 1) : 1

    self.next_level = self.policy.levels.with_entity_type(purchase_order.class.name).with_level_number(level_number).first


    if self.next_level.present?
      # If custom reviewer selected by initiator
      self.next_reviewer  = document.document_reviewer_mappable.with_level_id(next_level.id)
    end
  end

  def success
    params[:next_reviewer] = self.next_reviewer
    params[:next_level] = self.next_level
    ReviewalManager::NextReviewers::ShowPresenter.new(user, params, messages)
  end

  class ReviewalManager::NextReviewers::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :next_reviewer, :next_level

    def init
      self.next_level = params[:next_level]
      self.next_reviewer = params[:next_reviewer]
    end
  end
end