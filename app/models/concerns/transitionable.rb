module Transitionable
  extend ActiveSupport::Concern

  included do
    belongs_to :policy
    belongs_to :level, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id

    has_many :document_level_reviewer_mappings, as: :document_reviewer_mappable
    has_many :trails, as: :parent

    # New method for users
    #
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
        user_ids = self.document
      when 'reject', :reject # Users who will be affected
        user_ids += self.document_level_reviewer_mappings.pluck(:action_taken_by_id).reject {|user_id| user_id.nil?}
        user_ids.push self.document_owner.id # Check if this has to be added
      when 'unapprove', :unapprove
        user_ids += self.document_level_reviewer_mappings.with_apluck(:action_take_by_id)
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

    # # # Returns List of Users Who have interacted with the document
    # # def interacted_users
    # #   user_ids = self.document_level_reviewer_mappings.where(
    # #       viewable: true
    # #   ).pluck(:action_taken_by_id)
    # #   User.where(id: user_ids)
    # # end
    #
    # # # All Associated Users for a document (have taken action + yet to take action)
    # # def associated_users
    # #   # Users will be picked from DocumentLevelReviewerMapping
    # #   dlrm = self.document_level_reviewer_mappings.pluck()
    # # end
    #
    # # Includes users who have already approved the document
    # def reject_affected_users
    #
    #
    #   User.where(id: user_ids)
    # end
    #
    # # Skips users who have already approved the document
    # def retract_affected_users
    #   user_ids = []
    #
    #   user_ids
    # end

    # Get reviewers from current level
    def get_reviewers(level_details=nil, provider_name=nil)
      if [:next, :previous, 'next', 'previous', :current, 'current'].include? level_details
        level = get_level(level_details, provider_name)
      elsif level_details.is_a?(Integer)
          level = get_level_with_id(level_details, provider_name)
      else
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

    # Get reviewers from current level
    # def get_next_level_reviewers
    #   user_ids = []
    #   next_level = get_level(:next)
    #
    #   if next_level.present?
    #     taken_control_by_ids = []
    #     taken_control_by_ids += self.document_level_reviewer_mappings.with_level_id(next_level.id).pluck(:taken_control_by_id)
    #     taken_control_by_ids.reject! {|user_id| user_id.nil?}
    #     user_ids += taken_control_by_ids.present? ? taken_control_by_ids : self.document_level_reviewer_mappings.with_level_id(next_level.id).pluck(:reviewer_id)
    #   end
    #
    #   User.where(id: user_ids)
    # end
    #

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

      if self.level.present?
        current_level_number = self.level.level_number
        if type == 'next' || type == :next
          level_number = current_level_number + 1
        elsif ['previous', :previous, 'prev', :prev].include?(type)
          level_number = current_level_number - 1
        else
          return nil
        end
      else
        # If a document has already approved and you try to get next level, it will give you 1 putting it into loop
        # Or if you try to get previous level of a approved document, it will never be able to find it
        if self.class.status_ids(:retracted, :rejected, :open, :draft).include? self.status.id
          if type == 'next' || type == :next
            level_number = 1
          elsif ['previous', :previous, 'prev', :prev].include?(type)
            level_number = nil
          end
        else
          if type == 'next' || type == :next
            level_number = nil
          elsif ['previous', :previous, 'prev', :prev].include?(type)
            level_number = self.document_level_reviewer_mappings.pluck(:level_number).max
          end
        end
      end

      provider_name = provider_name || get_default_provider

      # if provider_name.present?
      #   reviewal_level_id = self.document_level_reviewer_mappings.with_level_number(level_number).first&.level_id
      # else
      # end
      reviewal_level_id = self.document_level_reviewer_mappings.with_level_number(level_number).with_provider_name(provider_name).first&.level_id

      ReviewalLevel.with_id(reviewal_level_id).first

      # ReviewalLevel.exclude_deleted.where({
      #                                         level_number: level_number,
      #                                         policy_id: self.policy.id,
      #                                         associated_entity_type: self.class.name
      #                                     }).first

      # Previously it was picked from policy's levels
      # todo - fix it
      # Bug: Let's say last level is deleted, it gonna approve without going to the last dlrm
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
            .where("#{self.document_status_attribute} in (?)", self.finance_associated_status_ids).pluck(:id)
      end
    end

    def creditor_associated_items(user)
      if user.instance_of?(User)
        policy_ids = PolicyUserRole.with_role_id(UserRole.id_for(:creditor)).where(user_id: user.id)
        self.where(policy_id: policy_ids)
            .where("#{self.document_status_attribute} in (?)", self.finance_associated_status_ids).pluck(:id)
      end
    end

    # todo setup travel request
    def travel_associated_items(user, role_id, purpose_id=1)
      if user.instance_of(User)

      end
    end
  end
end
