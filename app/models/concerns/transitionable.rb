module Transitionable
  extend ActiveSupport::Concern

  included do
    belongs_to :policy, optional: true
    belongs_to :level, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id, optional: true

    has_many :document_level_reviewer_mappings, as: :document_reviewer_mappable
    has_many :trails, as: :parent

    def document_owner_id
      self.send(self.class.document_owner_attribute)
    end

    def associated_users(type=nil)
      # Valid types [:retract, :reject, :all, :interacted, :unapprove]
      user_ids = []
      case type
      when 'retract', :retract # Users who will be affected
        if self.level.present?
          taken_control_by_ids = []
          # If the current level has been taken control by someone return their ids else the current reviewers in the level
          taken_control_by_ids =  self.document_level_reviewer_mappings.with_level_id(self.level.id).pluck(:taken_control_by_id)
          taken_control_by_ids.reject! {|user_id| user_id.nil?}
          user_ids += taken_control_by_ids.present? ? taken_control_by_ids : self.document_level_reviewer_mappings.with_level_id(self.level.id).pluck(:reviewer_id)
        end
      when 'reject', :reject # Users who will be affected
        user_ids += self.document_level_reviewer_mappings.pluck(:action_taken_by_id).reject {|user_id| user_id.nil?}
        user_ids.push self.document_owner_id # Check if this has to be added
      when 'unapprove', :unapprove
        user_ids += self.document_level_reviewer_mappings.pluck(:action_taken_by_id)
      when 'all', :all # Users who have interacted + who will interact in future
      when 'interacted', :interacted # User who have taken action the document
        user_ids = self.document_level_reviewer_mappings.where(
                                                            viewable: true
        ).pluck(:action_taken_by_id)
      else # Return all associated users
        return associated_users(:all)
      end

      User.where(id: user_ids)
    end

    def affected_users(type=nil)
      # Valid types [:retract, :reject, :all, :interacted, :unapprove]
      user_ids = []
      case type
      when :approve, 'approve'
        if self.class.status_ids(:approved).include? self.send(self.class.document_status_attribute)
          user_ids.push self.document_owner_id
          user_ids.push self.trails.with_action_id(TrailAction.id_for(:approve)).last.action_user_id
        else
          user_ids.push self.trails.with_action_id(TrailAction.id_for(:approve)).last.action_user_id
          user_ids += self.get_reviewers(self.controlling_level_id)&.map(&:id)
        end
      when :reject, 'reject'
        user_ids += self.document_level_reviewer_mappings.pluck(:action_taken_by_id).reject {|user_id| user_id.nil?}
        user_ids.push self.document_owner_id # Check if this has to be added
      when :retract, 'retract'
        # dlrms = self.document_level_reviewer_mappings.with_viewable
        # max_viewable_level_number = dlrms.maximum(:level_number)
        #
        # dlrms = dlrms.with_level_number(max_viewable_level_number)
        #
        # taken_control_by_ids = dlrms.pluck(:taken_control_by_id)
        # # If the current level has been taken control by someone return their ids else the current reviewers in the level
        # taken_control_by_ids.reject! {|user_id| user_id.nil?}
        #
        # user_ids += taken_control_by_ids.present? ? taken_control_by_ids : dlrms.pluck(:reviewer_id)
        #
        # NEW CODE
        last_retract_trail = self.trails.reload.with_action_id(TrailAction.id_for(:retract)).last

        user_ids += self.get_reviewers(last_retract_trail.action_level_id)&.map(&:id)
      when :submit, 'submit'
        user_ids.push self.document_owner_id
        user_ids += self.get_reviewers&.map(&:id)
      when :take_control, 'take_control'
        user_ids += self.document_level_reviewer_mappings.with_level_id(self.controlling_level_id).pluck(:reviewer_id)
        user_ids += self.document_level_reviewer_mappings.with_level_id(self.controlling_level_id).pluck(:taken_control_by_id)
      when :unapprove, 'unapprove'
        if self.class.status_ids(:approved).include? self.send(self.class.document_status_attribute)
          user_ids += self.get_reviewers(:next)&.map(&:id)
          user_ids.push self.document_owner_id
        else
          user_ids += self.get_reviewers(:nex)&.map(&:id)
        end
      when :comment, 'comment'
        user_ids += self.document_owner_id
      end

      User.with_id(user_ids)
    end

    def notification_affected_users(type=nil)
      # Valid types [:retract, :reject, :all, :interacted, :unapprove]
      user_ids = []
      case type
      when :approve, 'approve'
        if self.class.status_ids(:approved).include? self.send(self.class.document_status_attribute)
          user_ids.push self.send(self.class.document_owner_attribute)
        else
          user_ids += self.get_reviewers&.map(&:id)
        end
      when :submit, 'submit'
        user_ids += self.get_reviewers&.map(&:id)
      when :reject, 'reject'
        last_action_user_id = self.trails.last.action_user_id
        user_ids += self.document_level_reviewer_mappings.pluck(:action_taken_by_id).reject {|user_id| user_id.nil? || user_id == last_action_user_id }
        user_ids.push self.document_owner_id
      when :take_control, 'take_control'
        user_ids += self.document_level_reviewer_mappings.with_level_id(self.controlling_level_id).pluck(:reviewer_id)
      when :comment, 'comment'
        user_ids += self.document_owner_id
      when :unapprove, 'unapprove'
        if self.class.status_ids(:approved).include? self.send(self.class.document_status_attribute)
          user_ids += self.get_reviewers(:next)&.map(&:id)
          user_ids.push self.document_owner_id
        else
          user_ids += self.get_reviewers(:nex)&.map(&:id)
        end
      end

      User.with_id(user_ids)
    end

    def get_reviewal_chain(provider_name=nil)
      provider_name ||= get_default_provider
      dlrms = self.document_level_reviewer_mappings.with_provider_name(provider_name).includes(:level, :reviewer, :action_taken_by, :taken_control_by)
      chain = []

      dlrms.each do |dlrm|
        level_number = dlrm.level_number

        data = chain[level_number - 1] || {}

        data[:level_number] = dlrm.level_number
        data[:level_name] = dlrm.level.name
        data[:policy_id] = dlrm.policy_id
        data[:awaiting_action] = (self.controlling_level_id == dlrm.level_id)
        data[:action_taken] = data[:action_taken] || (dlrm.action_taken_by_id.present?)
        data[:reviewers] = data[:reviewers] || []
        reviewer = {
            id: dlrm.reviewer.id,
            name: dlrm.reviewer.name,
            active: dlrm.active,
            threshold: dlrm.threshold,
            action_taken: (dlrm.reviewer.id == dlrm.action_taken_by_id),
            action_name: dlrm.action&.name&.split("_")&.map(&:capitalize)&.join(" ")
        }
        data[:reviewers].push(reviewer)

        if dlrm.taken_control_by_id.present?
          data[:taken_control_by] = {
              id: dlrm.taken_control_by_id,
              name: dlrm.taken_control_by.name,
              action_taken: (dlrm.taken_control_by_id == dlrm.action_taken_by_id),
              action_name: dlrm.action&.name&.split("_")&.map(&:capitalize)&.join(" ")

          }
        end

        chain[level_number - 1] = data
      end

      # chain.reject {|item| item.blank? }
      # chain
      chain.map do |item|
        if item.blank?
          {skipped: true}
        else
          item
        end
      end
    end

    # Users who can take the current action on the document
    def action_users(type=nil)
      user_ids = []
      case type
      when 'unapprove', :unapprove
        user_ids.push self.trails.with_action_id(TrailAction.id_for(:approve)).last.action_user_id
      when 'return_control', :return_control
        if level.present?
          user_ids += document_level_reviewer_mappings.with_level_id(level.id).pluck(:taken_control_by_id).compact
        end
      else
        # nothing to do
      end

      User.with_id(user_ids)
    end

    # Get reviewers from current level
    def get_reviewers(level_details=nil, provider_name=nil)
      if [:next, :previous, 'next', 'previous', :current, 'current'].include? level_details
        level = get_level(level_details, provider_name)
      elsif level_details.is_a?(Integer)
        level = get_level_with_id(level_details, provider_name)
      else
        # if no level details passed, gives result for current level
        level = self.level
      end
      user_ids = []

      if level.present?
        taken_control_by_ids = []
        taken_control_by_ids += self.document_level_reviewer_mappings.with_level_id(level.id).pluck(:taken_control_by_id)
        taken_control_by_ids.reject! {|user_id| user_id.nil?}
        user_ids += taken_control_by_ids.present? ? taken_control_by_ids : self.document_level_reviewer_mappings.with_level_id(level.id).pluck(:reviewer_id)
      end

      User.where(id: user_ids)
    end

    def get_level_with_id(level_id, provider_name=nil)
      provider_name = provider_name || get_default_provider
      if self.document_level_reviewer_mappings.with_provider_name(provider_name).pluck(:level_id).include? level_id
        return ReviewalLevel.with_id(level_id).first
      end
      nil
    end

    def get_level(type, provider_name=nil)
      # provider_name - todo
      # Provide :next / :prev to get the respective levels
      # current_level_number = self.level.present? ? self.level.level_number : 0

      provider_name ||= get_default_provider

      all_level_numbers = self.document_level_reviewer_mappings.with_provider_name(provider_name).pluck(:level_number).uniq.sort


      # Return if dlrm not found
      return nil if all_level_numbers.blank?

      if self.level.present?
        current_level_number = self.level.level_number
        if type == 'next' || type == :next
          level_number = current_level_number + 1
        elsif ['previous', :previous, 'prev', :prev].include?(type)
          level_number = current_level_number - 1
        elsif [:current, 'current'].include?(type)
          return level
        else
          return nil
        end
      else
        # If a document has already approved and you try to get next level, it will give you 1 putting it into loop
        # Or if you try to get previous level of a approved document, it will never be able to find it
        if self.class.status_ids(:retracted, :rejected, :open, :draft, :selection_requested, :selection_rejected, :selection_rejected).include? self.status.id
          if type == 'next' || type == :next
            level_number = 1
          elsif ['previous', :previous, 'prev', :prev].include?(type)
            level_number = nil
            return
          end
        else
          if type == 'next' || type == :next
            level_number = nil
            return
          elsif ['previous', :previous, 'prev', :prev].include?(type)
            # level_number = self.document_level_reviewer_mappings.pluck(:level_number).max
            level_number = all_level_numbers.max
          end
        end
      end

      # If threshold for first level is higher than amount, & there is only one level its gonna give next level as nil and hence auto approve it
      # Below code will find the next/perv level if present with threshold
      if [:next, 'next'].include? type
        loop do
          break if all_level_numbers.include?(level_number) || (level_number > all_level_numbers.max)
          level_number += 1
        end
      elsif [:prev, :previous, 'prev', 'previous'].include? type
        loop do
          break if all_level_numbers.include?(level_number) || (level_number < all_level_numbers.min)
          level_number -= 1
        end
      else
        return nil
      end

      provider_name = provider_name || get_default_provider

      self.document_level_reviewer_mappings.with_level_number(level_number).with_provider_name(provider_name).first&.level
    end

    # In case reviewer wants to reject it to a particular user who had previously approved
    def reject_to_users
    end

    def can_return_control?
      return nil if level.blank?

      dlrms = self.document_level_reviewer_mappings.with_level_id(level.id)
      dlrms.each do |dlrm|
        # return false if dlrm.taken_control == false
        return false unless dlrm.taken_control
      end

      return true
    end

    def get_default_provider
      self.class.name + "Provider"
    end

    # Gives list of creditors for the document
    def document_role_users(type=nil)
      case type
      when :creditor, 'creditor', :creditors, 'creditors'
        user_role_id = UserRole.id_for(:creditor)
      when :finance_manager, 'finance_manager', :finance_managers, 'finance_managers'
        user_role_id = UserRole.id_for(:finance_manager)
      when :travel_manager, 'travel_manager', :travel_managers, 'travel_managers'
        user_role_id = UserRole.id_for(:travel_manager)
      else
        return []
      end

      policy = Policy.find_by id: self.policy_id

      return [] unless policy.present?

      user_ids = policy.policy_user_roles.with_role_id(user_role_id).pluck(:user_id)

      User.with_id(user_ids)
    end
  end

  module ClassMethods
    # Returns list of items for role 'Manager/Reviewer'

    # Known Bug -> If user retracts > Changes policy(results in deletion of all dlrm and user who had interacted with document before lose access to it)
    def reviewer_associated_items(user)
      if user.instance_of?(User)
        # Get controlling level id from all documents
        if self.column_names.include? 'company_id'
          controlling_level_ids = self.where(company_id: user.company.id).pluck(:controlling_level_id).reject { |document_id| document_id.nil? }
          # controlling_level_ids += DocumentLevelReviewerMapping.where(
          #                                                          document_reviewer_mappable_type: self.name,
          #                                                          taken_control: true,
          #                                                          taken_control_by_id: user.id
          # ).pluck(:level_id)
        else
          # Models like Report doesn't has company_id attribute
          user_ids = user.company.users.pluck(:id)

          controlling_level_ids = self.where("#{self.document_owner_attribute} in (?)", user_ids).pluck(:controlling_level_id).reject {|document_id| document_id.nil?}
        end

        # Get all the documents without viewable
        document_ids = DocumentLevelReviewerMapping.where(
                                                       reviewer_id: user.id,
                                                       document_reviewer_mappable_type: self.name,
                                                       level_id: controlling_level_ids
        ).pluck(:document_reviewer_mappable_id)

        # Get all the documents where the user had previously interacted with
        document_ids += DocumentLevelReviewerMapping.where(
            reviewer_id: user.id,
            document_reviewer_mappable_type: self.name,
            viewable: true,
        ).pluck(:document_reviewer_mappable_id)

        # Get all the taken control items for admin user
        document_ids += DocumentLevelReviewerMapping.where(
                                                        taken_control: true,
                                                        document_reviewer_mappable_type: self.name,
                                                        taken_control_by_id: user.id
        ).pluck(:document_reviewer_mappable_id)

        self.where(id: document_ids)
      end
    end

    #todo below
    # Displays all document. Need to remove draft state
    # # Only gives result for admins and reviewers
    def awaiting_action_items(user)
      if user.instance_of?(User)
        # Do nothing
      elsif user.is_a?(Integer)
        user = User.find_by id: user
        return [] unless user.present?
      else
        return []
      end

      if self.column_names.include? 'company_id'
        document_ids = self.where(company_id: user.company.id).pluck(:id)
      else
        user_ids = user.company.users.pluck(:id)
        document_ids = self.where("#{self.document_owner_attribute} in (?)", user_ids).pluck(:id)
      end

      controlling_level_ids = self.where(id: document_ids).pluck(:controlling_level_id)

      new_document_ids = DocumentLevelReviewerMapping.where(level_id: controlling_level_ids).where(taken_control_by_id: user.id).pluck(:document_reviewer_mappable_id)
      new_document_ids += DocumentLevelReviewerMapping.where(level_id: controlling_level_ids).where(reviewer_id: user.id).pluck(:document_reviewer_mappable_id)

      self.where(id: new_document_ids)
    end


    def admin_associated_items(user)
      if user.instance_of?(User)
        if self.column_names.include? 'company_id'
          document_ids = self.where(company_id: user.company.id).pluck(:id)
        else
          user_ids = user.company.users.pluck(:id)
          document_ids = self.where("#{self.document_owner_attribute} in (?)", user_ids).pluck(:id)
        end
        self.where(id: document_ids)
      end
    end

    def finance_associated_items(user)
      if user.instance_of?(User)
        policy_ids = PolicyUserRole.with_role_id(UserRole.id_for(:finance_manager)).where(user_id: user.id).pluck(:policy_id)
        self.where(policy_id: policy_ids)
            .where("#{self.document_status_attribute} in (?)", self.finance_associated_status_ids)
      end
    end

    def creditor_associated_items(user)
      if user.instance_of?(User)
        policy_ids = PolicyUserRole.with_role_id(UserRole.id_for(:creditor)).where(user_id: user.id).pluck(:policy_id)
        self.where(policy_id: policy_ids)
            .where("#{self.document_status_attribute} in (?)", self.finance_associated_status_ids)
      end
    end

    # todo setup travel request
    def travel_associated_items(user)
      if user.instance_of?(User)
        policy_ids = PolicyUserRole.with_role_id(UserRole.id_for(:travel_manager)).where(user_id: user.id).pluck(:policy_id)
        self.where(policy_id: policy_ids)
            .where("#{self.document_status_attribute} in (?)", self.travel_associated_status_ids)
      end
    end
  end
end
