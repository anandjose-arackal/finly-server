class WorkflowManager::Aasm::BaseProvider
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

  @@providers = []

  def self.providers
    @@providers
  end

  def self.register_provider
    @@providers << self.name.split('::').last
  end

  self.register_provider

  private

  def set_state
    Dir[Rails.root.join("app/operations/workflow_manager/aasm/*.rb")].each {|file| require file }
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

  def change_state
    # Update Document Level Reviewer Mapping
    # find current document_level_reviewer_mappings
    if [:approve, :reject].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings
                 .where(level_id: current_level.id, policy_id: document.policy.id)
                 .where("taken_control_by_id = ? or reviewer_id = ?", user.id, user.id).first

      if dlrm.present?
        dlrm.update({
                        action_id: TrailAction.id_for(aasm.current_event),
                        viewable: true,
                        action_taken_by_id: user.id

                    })
      end
    end

    if [:take_control].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings
          .where(level_id: current_level.id, policy_id: document.policy.id)

      if dlrm.present?
        dlrm.update_all(taken_control_by_id: user.id, taken_control: true)
      end
    end

    if [:return_control].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings
          .where(level_id: current_level.id, policy_id: document.policy.id)

      if dlrm.present?
        dlrm.update_all(taken_control_by_id: nil, taken_control: false)
      end
    end

    if [:retract].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings
      dlrm.update_all(
          taken_control: false,
          taken_control_by_id: nil,
          action_taken_by_id: nil,
          action_id: nil
      )
    end

    if [:reject].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings
      dlrm.update_all(
              taken_control: false,
              taken_control_by_id: nil,
              action_taken_by_id: nil,
              action_id: nil
      )
    end

    # reset levels
    # if [:retract, :reject].include?(aasm.current_event)
    #   self.new_level = nil
    # end
    if [:submit, :approve].include?(aasm.current_event)
      self.new_level = self.next_level
    end

    if [:take_control, :return_control].include?(aasm.current_event)
      self.new_level = self.current_level
    end

    if [:unapprove].include?(aasm.current_event)
      self.new_level = self.previous_level
    end


    status_id = document.status.class.id_for(self.aasm.current_state)
    update_params = {
        controlling_level_id: self.new_level&.id
    }
    update_params[document.class.document_status_attribute] = status_id

    self.document.update(update_params)
  end

  def approvers_not_present?
  end

  def reviewers_not_present?
    self.reviewers.blank?
  end
end