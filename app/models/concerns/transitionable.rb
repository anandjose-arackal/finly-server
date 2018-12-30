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
      if self.level_id.present?
        # If the current level has been taken control by someone return their ids else the current reviewers in the level
        taken_control_by_ids =  self.document_level_reviewer_mappings.with_level_id(self.level_id).pluck(:taken_control_by_ids)
        user_ids += taken_control_by_ids.present? ? taken_control_by_ids : self.document_level_reviewer_mappings.with_level_id(self.level_id).pluck(:reviewer_id)
      end
      user_ids
    end

    # Get reviewers from current level
    def get_reviewers
      user_ids = []
      if self.level.present?
        taken_control_by_ids += self.document_level_reviewer_mappings.with_level_id(self.level.id).pluck(:taken_control_by_ids)
        user_ids += taken_control_by_ids.present? ? taken_control_by_ids : self.document_level_reviewer_mappings.with_level_id(self.level.id).pluck(:reviewer_id)
      end

      User.where(id: user_ids)
    end

    # Get reviewers from current level
    def get_next_level_reviewers
      user_ids = []
      next_level = get_level(:next)
      if next_level.present?
        taken_control_by_ids += self.document_level_reviewer_mappings.with_level_id(next_level.id).pluck(:taken_control_by_ids)
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
                                              associated_entity_type: self.name
                                          }).first
    end

    # In case reviewer wants to reject it to a particular user who had previously approved
    def reject_to_users
    end


  end

  module ClassMethods
    # Returns list of items for role 'Manager/Reviewer'
    def associated_items(user)
      if user.instance_of?(User)
        document_ids = DocumentLevelReviewerMapping.where(
            reviewer_id: user.id,
            document_reviewer_mappable_type: self.name,
        ).pluck(:document_reviewer_mappable_id)

        self.where(id: document_ids)
      end
    end
  end
end
