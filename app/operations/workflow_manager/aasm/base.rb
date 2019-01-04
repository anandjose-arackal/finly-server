class WorkflowManager::Aasm::Base
  include AASM
  attr_accessor :document_state, :document, :user, :violations_present, :policy,
                :current_level, :next_level, :previous_level,
                :current_level_reviewers, :reviewers, :new_level

  def initialize(document, violations_present, user)
    self.document = document
    self.violations_present = violations_present
    self.aasm.current_state = self.document.status.name.downcase.to_sym ## Have to take care where status is stored in a different attribute
    self.user = user
    self.policy = self.document.policy ## Have to take care where status is stored in a different attribute

    # get reviewers
    self.current_level = document.level
    self.next_level = document.get_level(:next)
    self.previous_level = document.get_level(:prev)
    self.current_level_reviewers = document.get_reviewers
    self.reviewers = document.get_next_level_reviewers
  end

  private

  def set_state
    aasm.current_state = self.document_state
  end

  def document_amount
    amount = 0
    case document.class.name
      when 'Report'
        amount = document.total_amount
    end

    amount
  end

  def approvers_not_present?
  end

  def reviewers_not_present?
    self.reviewers.blank?
  end
end