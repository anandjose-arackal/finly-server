class WorkflowManager::Aasm::BaseProvider
  include AASM

  attr_accessor :document_state, :document, :user, :violations_present, :policy,
                :current_level, :next_level, :previous_level,
                :current_level_reviewers, :reviewers, :new_level, :document_update_params, :provider_name

  def initialize(document, violations_present, user, provider_name=nil)
    self.document = document
    self.violations_present = violations_present
    self.aasm.current_state = self.document.status.name.downcase.to_sym ## Have to take care where status is stored in a different attribute
    self.user = user
    self.policy = self.document.policy ## Have to take care where status is stored in a different attribute
    self.provider_name = provider_name || self.document.get_default_provider

    # get reviewers
    self.current_level = document.level
    self.next_level = document.get_level(:next)
    self.previous_level = document.get_level(:prev)
    self.current_level_reviewers = document.get_reviewers
    self.reviewers = document.get_reviewers(:next)
    self.document_update_params = {}
  end

  private

  def set_state
    # Dir[Rails.root.join("app/operations/workflow_manager/aasm/*.rb")].each {|file| require file }
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
    ### :change_state has been broken down into three different methods
    ### so it can be overridden in any of the providers

    # Update DLRMs for the document
    update_dlrms

    # Update new level(Usually next level unless its a retract of unapprove)
    update_levels

    # Update the status of the document
    update_status
  end

  def update_dlrms
    if [:submit].include?(aasm.current_event)
      self.document_update_params[:submitted_at] = DateTime.now
      dlrms = document.document_level_reviewer_mappings.with_level_id(next_level&.id).with_policy_id(policy.id)

      # Set viewable true for the next level when document is submitted
      if dlrms.present?
        dlrms.update_all(viewable: true)
      end
    end


    # Update Document Level Reviewer Mapping
    # find current document_level_reviewer_mappings
    if [:approve, :reject].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings.with_level_id(current_level.id).with_policy_id(policy.id)
                 .where("taken_control_by_id = ? or reviewer_id = ?", user.id, user.id).first

      if dlrm.present?
        dlrm.update(
            action_id: TrailAction.id_for(aasm.current_event),
            action_taken_by_id: user.id
        )
      end
    end

    if [:approve].include?(aasm.current_event)
      if next_level.present?
        next_dlrms = document.document_level_reviewer_mappings.with_level_id(next_level.id).with_policy_id(policy.id)

        next_dlrms.update_all(viewable: true)
      else
        self.document_update_params[:approved_at] = DateTime.now
      end
    end

    if [:unapprove].include?(aasm.current_event)
      unapprove_level = previous_level.present? ? previous_level : current_level
      dlrm = document.document_level_reviewer_mappings
        .where(level_id: unapprove_level&.id, policy_id: document.policy.id).where.not(action_taken_by_id: nil).first

      dlrm.update(
          action_taken_by_id: nil,
          action_id: TrailAction.id_for(aasm.current_event)
      )

    end

    if [:take_control].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings
          .where(level_id: current_level.id, policy_id: document.policy.id)

      if dlrm.present?
        dlrm.update_all(taken_control_by_id: user.id, taken_control: true, active: false)
      end
    end

    if [:return_control].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings
          .where(level_id: current_level.id, policy_id: document.policy.id)

      if dlrm.present?
        dlrm.update_all(taken_control_by_id: nil, taken_control: false, active: true)
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

  end

  def update_levels
    # :retract & :reject should set level to nil; which it already is

    # :submit & :approve should move to next level
    if [:submit, :approve].include?(aasm.current_event)
      self.new_level = self.next_level
    end

    if [:approve].include?(aasm.current_event)
      unless self.next_level.present?
      end
    end

    # :take_control and :return_control should remain in the same level
    if [:take_control, :return_control].include?(aasm.current_event)
      self.new_level = self.current_level
    end

    # :unapprove should move one level back
    if [:unapprove].include?(aasm.current_event)
      self.new_level = self.previous_level
    end
  end

  # Update status of the document
  def update_status
    status_id = document.status.class.id_for(self.aasm.current_state)
    self.document_update_params[:controlling_level_id] = self.new_level&.id
    self.document_update_params[document.class.document_status_attribute] = status_id
    self.document.update(self.document_update_params)
  end

  # def approvers_not_present?
  # end

  def reviewers_not_present?
    self.reviewers.blank?
  end

  def user_can_review?
    self.current_level_reviewers.include?(user)
  end
end
