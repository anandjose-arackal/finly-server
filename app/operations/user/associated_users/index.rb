class User::AssociatedUsers::Index < User::AssociatedUsers::Base
  attr_accessor :associated_users, :tracks, :user_before

  def process
    user_ids = load_interacted_users
    # todo load pending review users based on params. Not using anywhere as of now

    if user_ids.size > 0
      # Order is MySQL Specific
      user_ids = user_ids.reverse!
      user_ids.reject! { |id| id.blank? }
      self.associated_users = User.with_id(user_ids).with_company_id(self.user.company_id).order("field(id,#{user_ids.join(',')})")
    end
  end

  def success
    self.associated_users
  end

  protected
  def load_interacted_users
    tracking = self.trails.includes(:modified_level, :action_level, :action_user)
    if self.user_before.present?
      track = tracking.find_by(action_user_id: user_before.id)
      unless track.blank?
        tracking = tracking.created_before(track.created_at)
      end
    end

    # Caching to save associated user roles in model attr_accessor incase user role is triggered after associated_users
    # todo handle configuration for cache to track if user_before was used or not.
    # # # todo Because if user_before was used, then the cached data is going to be only for those users. If UserRole is called, then it returns from this cached data
    # cache_user_roles tracking, :interacted_roles


    action_user_ids = tracking.map(&:action_user_id)
    modified_level_ids = tracking.map(&:modified_level_id)
    modified_levels = ::ReviewalLevel.with_ids(modified_level_ids)
    modified_level_user_ids = []
    # modified_levels.each do |level|
    #   reviewer_ids = level.level_reviewer_mappings.with_threshold(self.amount).pluck(:reviewer_id)
    #   modified_level_user_ids += reviewer_ids
    # end


    # Test
    modified_levels.each do |level|
      controlling_user_ids = level.level_reviewer_mappings.with_threshold(self.amount).pluck(:reviewer_id)

      user_selected_reviewer = document.document_level_reviewer_mappings.with_level_ids(level.id).last&.reviewer

      if user_selected_reviewer.present? && controlling_user_ids.include?(user_selected_reviewer.id)
        # Check if user selected reviewer is satisfies level reviewer mapping threshold criteria
        modified_level_user_ids.push(user_selected_reviewer.id)
      else
        # User selected reviewer is not present in list of users satisfying current level's threshold criteria
        # select all the threshold satifying reviewers
        modified_level_user_ids += controlling_user_ids
      end
    end

    # Test ends

    user_ids = action_user_ids + modified_level_user_ids

    # user_ids = (tracking.map(&:action_user_id) + tracking.map(&:modified_user_id))
    #
    # # If unapprove, adding the current controlling user
    # if self.report.controlling_user_id.present? and (user_before.blank? or user_before.id != self.report.controlling_user_id)
    #   if self.report.controlling_for_user_id.present?
    #     user_ids << self.report.controlling_for_user_id
    #   else
    #     user_ids << self.report.controlling_user_id
    #   end
    # end

    # User IDs was blank when an admin was taking control of his own report and rejecting it. This is the fix
    if user_ids.present?
      user_ids.uniq!
    else
      user_ids = [self.user.id]
    end
    user_ids
  end

  ##### todo need to get clarification on the following
  # def cache_user_roles(tracking, type)
  #   return if tracking.blank?
  #   # Load Report Cache from tracking
  #   self.report.cache_users = {} if self.report.cache_users.blank?
  #   tracking.each do |track|
  #     [[track.action_user_id, track.action_user_role_id], [track.modified_user_id, track.modified_user_role_id]].each do |item|
  #
  #       id = item[0]
  #       if self.report.cache_users[id].blank?
  #         self.report.cache_users[id] = {}
  #       end
  #       if self.report.cache_users[id][type].blank?
  #         self.report.cache_users[id][type] = []
  #       end
  #
  #       map = self.report.cache_users[id][type]
  #       map << item[1] unless map.include?(item[1]) or item[1].nil?
  #     end
  #   end
  # end

end