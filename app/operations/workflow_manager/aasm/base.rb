class WorkflowManager::Aasm::Base
  include AASM
  attr_accessor :document_state, :document, :user, :violations_present, :policy, :current_level, :next_level

  def initialize(document, violations_present, user)
    self.document = document
    self.violations_present = violations_present
    self.aasm.current_state = self.document.status.name.downcase.to_sym ## Have to take care where status is stored in a different attribute
    self.user = user
    self.policy = self.document.policy ## Have to take care where status is stored in a different attribute
    set_levels
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

  def reviewers_not_present?
    if self.policy.present?
      if self.next_level.present?
        if self.next_level.level_reviewer_mappings.with_threshold(document_amount).present?
          return false
        else
          return true
        end
      else
        return true
      end
    else
      true
    end
  end

  def set_levels
    # total_amount = purchase_order.total_amount
    self.current_level = ReviewalLevel.with_id(document.controlling_level_id).first
    level_number = current_level.present? ? (current_level.level_number + 1) : 1
    self.next_level = self.policy.levels.with_entity_type(document.class.name).with_level_number(level_number).first
  end

  def previous_level
    self.current_level = ReviewalLevel.with_id(document.controlling_level_id).first
    if current_level.present? && current_level.level_number > 1
      level_number = current_level.level_number - 1
      level = self.policy.levels.with_entity_type(document.class.name).with_level_number(level_number).first
    else
      level = nil
    end
    level
  end


end