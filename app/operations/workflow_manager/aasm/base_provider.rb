class WorkflowManager::Aasm::BaseProvider
  include AASM

  attr_accessor :document_state, :document, :user, :violations_present, :policy, :policy_id,
                :current_level, :next_level, :previous_level, :forwarded_to_user,
                :current_level_reviewers, :reviewers, :new_level, :document_update_params, :provider_name, :error_message,
                :reject_to_user, :reject_to_level, :messages

  def initialize(user, params)
    self.user = user
    self.messages = {success: [], error: []}

    self.document = params[:document]
    self.violations_present = params[:violations_present]
    self.forwarded_to_user = params[:forwarded_to_user]
    self.provider_name = params[:provider_name] || self.document.get_default_provider

    self.aasm.current_state = self.document.status.name.downcase.to_sym ## Have to take care where status is stored in a different attribute

    self.policy_id = self.document.policy_id
    self.policy = Policy.find_by id: self.policy_id ## Have to take care where status is stored in a different attribute

    # get reviewers
    self.current_level = self.document.level
    self.next_level = self.document.get_level(:next, provider_name)
    self.previous_level = self.document.get_level(:prev, provider_name)
    self.current_level_reviewers = self.document.get_reviewers(nil, provider_name)
    self.reviewers = self.document.get_reviewers(:next, provider_name)
    self.document_update_params = {}

    # used for knowing if the document would be rejected to a specific level in the approval chain
    self.reject_to_user = self.user.company.users.with_id(params[:reject_to_user])&.first
    self.reject_to_level = self.document.get_level_with_id(params[:reject_to_level].to_i)
  end

  private

  def set_state
    # Dir[Rails.root.join("app/operations/workflow_manager/aasm/*.rb")].each {|file| require file }
    aasm.current_state = self.document_state
  end

  # Not being Used?!
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

    # Update PaperTrail Event
    update_paper_trail_event

    # Update DLRMs for the document
    update_dlrms

    # Update new level(Usually next level unless its a retract of unapprove)
    update_levels

    # Update the status of the document
    update_status

    # Add Success Message
    add_success_message

    # Broadcast event
    broadcast_event

    # Create new PaperTrail version
    create_paper_trail_version
  end

  def update_dlrms
    if [:submit].include?(aasm.current_event)
      self.document_update_params[:submitted_at] = DateTime.now
      dlrms = document.document_level_reviewer_mappings.with_level_id(next_level&.id).with_policy_id(self.policy_id)

      # Set viewable true for the next level when document is submitted
      if dlrms.present?
        dlrms.update_all(viewable: true)
      end
    end

    if [:forward].include?(aasm.current_event)
      dlrms = document.document_level_reviewer_mappings.with_level_id(current_level.id).with_policy_id(self.policy_id)

      # Set forwarding user
      if dlrms.present?

        # Calculate TAT
        if previous_level.present?
          previous_level_dlrms = document.document_level_reviewer_mappings
                                     .where(level_id: previous_level.id, policy_id: document.policy_id).where.not(action_taken_by_id: nil)
          time_0 = previous_level_dlrms.map(&:action_taken_at).compact.max
        else
          time_0 = [document.submitted_at, document.trails.with_action_id(TrailAction.id_for(:submit)).last.created_at].compact.max
        end
        tat = Time.now - time_0

        dlrms.update_all({forwarded: true, forwarded_by_id: user.id, forwarded_to_id: forwarded_to_user.id, active: false, taken_control: false, taken_control_by_id: nil, action_taken_at: DateTime.now, tat: tat})
      end
    end


    # Update Document Level Reviewer Mapping
    # find current document_level_reviewer_mappings
    if [:approve].include?(aasm.current_event)
      dlrms = document.document_level_reviewer_mappings.with_level_id(current_level.id).with_policy_id(self.policy_id)
                 .where("taken_control_by_id = ? or reviewer_id = ? or forwarded_to_id = ?", user.id, user.id, user.id)

      # Calculate TAT
      # Handles scenario where document was rejected to level
      last_rejected_at = dlrms.pluck(:rejected_by_id).compact.present? ? document.trails.with_action_id(TrailAction.id_for(:reject)).reorder(:created_at).last&.created_at : nil

      # Find ifany submit/approve actions were after the last reject to level
      approval_submission_post_rejection = last_rejected_at.present? ? document.trails.with_action_id(TrailAction.ids_for(:submit, :approve)).where("created_at > ?", last_rejected_at) : []

      if approval_submission_post_rejection.present? || last_rejected_at.blank?
        # ifany submit/approve actions are found after last reject to level, then continue to find tat from previous level or submitted at
        if previous_level.present?
          previous_level_dlrms = document.document_level_reviewer_mappings
                                     .where(level_id: previous_level.id, policy_id: document.policy_id).where.not(action_taken_by_id: nil)

          time_0 = previous_level_dlrms.map(&:action_taken_at).compact.max

          # Some of the cases action_taken_at is missing for dlrms
          time_0 = document.trails.with_action_id(TrailAction.id_for(:approve)).where(action_level_id: previous_level.id).map(&:created_at).max if time_0.blank?
        else
          time_0 = [document.submitted_at, document.trails.with_action_id(TrailAction.id_for(:submit)).last&.created_at].compact.max
        end

        tat = Time.now - time_0
      else
        # ifany submit/approve actions are NOT present after last reject to level, then tat will be considered from last rejection
        tat = Time.now - last_rejected_at
      end

      if dlrms.present?
        dlrms.update_all(
            action_id: TrailAction.id_for(aasm.current_event),
            action_taken_by_id: user.id,
            action_taken_at: DateTime.now,
            tat: tat
        )
      end

      # Set Viewable True for Next Levels
      if next_level.present?
        next_dlrms = document.document_level_reviewer_mappings.with_level_id(next_level.id).with_policy_id(self.policy_id)
        next_dlrms.update_all(viewable: true)
      else
        # If Approved; Set Approved at
        self.document_update_params[:approved_at] = DateTime.now
      end
    end

    if [:unapprove].include?(aasm.current_event)
      unapprove_level = previous_level.present? ? previous_level : current_level
      dlrm = document.document_level_reviewer_mappings
        .where(level_id: unapprove_level&.id, policy_id: document.policy_id).where.not(action_taken_by_id: nil).first

      dlrm.update(
          action_taken_by_id: nil,
          action_id: TrailAction.id_for(aasm.current_event),
          action_taken_at: DateTime.now
      )

    end

    if [:take_control].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings
          .where(level_id: current_level.id, policy_id: document.policy_id)

      if dlrm.present?
        dlrm.update_all(taken_control_by_id: user.id, taken_control: true, active: false, action_taken_at: DateTime.now, forwarded: false, forwarded_by_id: nil, forwarded_to_id: nil)
      end
    end

    if [:return_control].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings
          .where(level_id: current_level.id, policy_id: document.policy_id)

      if dlrm.present?
        dlrm.update_all(taken_control_by_id: nil, taken_control: false, active: true, action_taken_at: DateTime.now)
      end
    end

    if [:retract].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings
      dlrm.update_all(
          taken_control: false,
          taken_control_by_id: nil,
          action_taken_by_id: nil,
          forwarded: false,
          forwarded_to_id: nil,
          forwarded_by_id: nil,
          action_id: nil,
          action_taken_at: nil,
          tat: nil
      )
    end

    if [:reject].include?(aasm.current_event)
      if self.reject_to_user.present? && self.reject_to_level.present?
        # for the level where it is rejected, remove the action details so that user in that level can take action again after correcting the document
        document.document_level_reviewer_mappings.where('level_id = ?', self.reject_to_level.id).update_all(action_taken_by_id: nil, action_id: nil, rejected_by_id: user.id, action_taken_at: DateTime.now)
        # for levels above the rejected level, remove all action details
        dlrm = document.document_level_reviewer_mappings.where('level_id > ?', self.reject_to_level.id)
      else
        dlrm = document.document_level_reviewer_mappings
      end
      dlrm.update_all(
              taken_control: false,
              taken_control_by_id: nil,
              action_taken_by_id: nil,
              forwarded: false,
              forwarded_to_id: nil,
              forwarded_by_id: nil,
              action_id: nil,
              action_taken_at: DateTime.now
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
    if [:take_control, :return_control, :forward].include?(aasm.current_event)
      self.new_level = self.current_level
    end

    # :unapprove should move one level back
    if [:unapprove].include?(aasm.current_event)
      self.new_level = self.previous_level
    end

    # if document is rejected to a specific level
    if [:reject].include?(aasm.current_event) && self.reject_to_user.present? && self.reject_to_level.present?
      self.new_level = self.reject_to_level
    end
  end

  # Update status of the document
  def update_status
    status_id = document.class.document_status_class_name.constantize.id_for(self.aasm.current_state)
    self.document_update_params[:controlling_level_id] = self.new_level&.id
    self.document_update_params[document.class.document_status_attribute] = status_id
    self.document.update(self.document_update_params)
  end

  def add_success_message
    case aasm.current_event
    when :submit, 'submit'
      if aasm.current_state == :auto_approved
        self.messages[:success].push "#{document_human_name} submitted"
        self.messages[:success].push "#{document_human_name} has been auto approved"
      else
        self.messages[:success].push "#{document_human_name} submitted"
      end
    when :retract, 'retract'
      self.messages[:success].push "#{document_human_name} retracted"
    when :reject, 'reject'
      self.messages[:success].push "#{document_human_name} rejected"
    when :approve, 'approve'
      self.messages[:success].push "#{document_human_name} approved"
    when :take_control, 'take_control'
      self.messages[:success].push "You've taken control of this #{document_human_name}"
    when :return_control, 'return_control'
      self.messages[:success].push "You've returned control of this #{document_human_name}"
    when :return_control, 'return_control'
      self.messages[:success].push "You've returned control of this #{document_human_name}"
    when :void, 'void'
      self.messages[:success].push "#{document_human_name} voided"
    else
      self.messages[:success].push "Successfully Performed Action"
    end
  end

  def broadcast_event
    #Events::Publisher::Record::Transition(document, user, user.company, aasm.current_event, aasm.current_state)
  end

  def update_paper_trail_event
    if self.document.respond_to?(:paper_trail_event)
      self.document.paper_trail_event = aasm.current_event.to_s.humanize.split.map(&:capitalize)&.join(' ')
    end
  end

  def create_paper_trail_version
    #below action not chnage any value in document
    #DLRM are updating with updat_all without callback soe we manually saving a version
    if self.document.respond_to?(:paper_trail_event)
      if [:forward, :take_control, :return_control].include?(aasm.current_event)
        self.document.paper_trail.save_with_version
      end
    end
  end


  def reviewers_not_present?
    self.reviewers.blank?
  end

  def reviewers_present?
    self.reviewers.present?
  end

  def user_can_review?
    self.current_level_reviewers.include?(user)
  end

  def user_can_unapprove?
    self.document.get_reviewers(:prev, provider_name).include?(user)
  end

  def reject_to_level?
    reject_to_level.present? and reject_to_user.present?
  end

  def document_human_name
    if document.class.respond_to?(:human_name)
      document.class.human_name
    else
      document.class.model_name.human.split(" ").map(&:capitalize).join(" ")
    end
  end
end
