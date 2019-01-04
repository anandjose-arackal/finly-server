module Transitionable
  extend ActiveSupport::Concern

  included do
    belongs_to :policy
    belongs_to :level, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id

    has_many :document_level_reviewer_mappings, as: :document_reviewer_mappable
    has_many :trails, as: :parent

    # Returns List of Users Who have interacted with the document
    def interacted_users
      user_ids = self.document_level_reviewer_mappings.where(
          viewable: true
      ).pluck(:action_taken_by_id)
      User.where(id: user_ids)
    end

    # All Associated Users for a document (have taken action + yet to take action)
    def associated_users
      # Users will be picked from DocumentLevelReviewerMapping
      dlrm = self.document_level_reviewer_mappings.pluck()
    end

    # Includes users who have already approved the document
    def reject_affected_users
      user_ids = []
      user_ids += self.document_level_reviewer_mappings.pluck(:action_taken_by_id)
      user_ids.push self.document_owner.id # Check if this has to be added

      User.where(id: user_ids)
    end

    # Skips users who have already approved the document
    def retract_affected_users
      user_ids = []
      if self.level.present?
        taken_control_by_ids = []
        # If the current level has been taken control by someone return their ids else the current reviewers in the level
        taken_control_by_ids =  self.document_level_reviewer_mappings.with_level_id(self.level.id).pluck(:taken_control_by_id)
        taken_control_by_ids.reject! {|user_id| user_id.nil?}
        user_ids += taken_control_by_ids.present? ? taken_control_by_ids : self.document_level_reviewer_mappings.with_level_id(self.level.id).pluck(:reviewer_id)
      end
      user_ids
    end

    # Get reviewers from current level
    def get_reviewers
      user_ids = []
      if self.level.present?
        taken_control_by_ids = []
        taken_control_by_ids += self.document_level_reviewer_mappings.with_level_id(self.level.id).pluck(:taken_control_by_id)
        taken_control_by_ids.reject! {|user_id| user_id.nil?}
        user_ids += taken_control_by_ids.present? ? taken_control_by_ids : self.document_level_reviewer_mappings.with_level_id(self.level.id).pluck(:reviewer_id)
      end

      User.where(id: user_ids)
    end

    # Get reviewers from current level
    def get_next_level_reviewers
      user_ids = []
      next_level = get_level(:next)

      if next_level.present?
        taken_control_by_ids = []
        taken_control_by_ids += self.document_level_reviewer_mappings.with_level_id(next_level.id).pluck(:taken_control_by_id)
        taken_control_by_ids.reject! {|user_id| user_id.nil?}
        user_ids += taken_control_by_ids.present? ? taken_control_by_ids : self.document_level_reviewer_mappings.with_level_id(next_level.id).pluck(:reviewer_id)
      end

      User.where(id: user_ids)
    end

    def get_level(type)
      # Provide :next / :prev to get the respective levels
      current_level_number = self.level.present? ? self.level.level_number : 0
      if type == 'next' || type == :next
        level_number = current_level_number + 1
      elsif ['previous', :previous, 'prev', :prev].include?(type)
        level_number = current_level_number - 1
      else
        return nil
      end

      ReviewalLevel.exclude_deleted.where({
                                              level_number: level_number,
                                              policy_id: self.policy.id,
                                              associated_entity_type: self.class.name
                                          }).first
    end

    # In case reviewer wants to reject it to a particular user who had previously approved
    def reject_to_users
    end


  end

  module ClassMethods
    # Returns list of items for role 'Manager/Reviewer'

    # Known Bug -> If user retracts > Changes policy(results in deletion of all dlrm and user who had interacted with document before lose access to it)
    def reviewer_associated_items(user)
      if user.instance_of?(User)
        # todo - While writing for invoice , owner of the document is stored at owner_id
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
          controlling_level_ids = self.where(user_id: user_ids).pluck(:controlling_level_id).reject {|document_id| document_id.nil?}
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

        document_ids += DocumentLevelReviewerMapping.where(
                                                        taken_control: true,
                                                        document_reviewer_mappable_type: self.name,
                                                        taken_control_by_id: user.id
        )

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
          document_ids = self.where(user_id: user_ids).pluck(:id)
        end
        self.where(id: document_ids)
      end
    end
  end
end
