class Procurements::AssociatedUsers < BaseOperation
  attr_accessor :associated_users, :tracks, :user_before

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
    end
    if params.blank? or (params[:id].blank? and params[:report_id].blank? and params[:report].blank?)
      add_message :error, 'Report not found'
    end
  end

  def init
    self.report = params[:report]
    super if self.report.blank?
    if self.report.present?
      self.tracks = report.tracks
    end
    self.user_before = params[:user_before]
  end

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
    tracking = self.tracks.includes(:modified_user, :action_user)
    if self.user_before.present?
      track = tracking.find_by(action_user_id: user_before.id)
      unless track.blank?
        tracking = tracking.created_before(track.created_at)
      end
    end

    # Caching to save associated user roles in model attr_accessor incase user role is triggered after associated_users
    # todo handle configuration for cache to track if user_before was used or not.
    # # # todo Because if user_before was used, then the cached data is going to be only for those users. If UserRole is called, then it returns from this cached data
    cache_user_roles tracking, :interacted_roles

    user_ids = (tracking.map(&:action_user_id) + tracking.map(&:modified_user_id))

    # If unapprove, adding the current controlling user
    if self.report.controlling_user_id.present? and (user_before.blank? or user_before.id != self.report.controlling_user_id)
      if self.report.controlling_for_user_id.present?
        user_ids << self.report.controlling_for_user_id
      else
        user_ids << self.report.controlling_user_id
      end
    end

    # User IDs was blank when an admin was taking control of his own report and rejecting it. This is the fix
    if user_ids.present?
      user_ids.uniq!
    else
      user_ids = [self.user.id]
    end
    user_ids
  end

  def cache_user_roles(tracking, type)
    return if tracking.blank?
    # Load Report Cache from tracking
    self.report.cache_users = {} if self.report.cache_users.blank?
    tracking.each do |track|
      [[track.action_user_id, track.action_user_role_id], [track.modified_user_id, track.modified_user_role_id]].each do |item|

        id = item[0]
        if self.report.cache_users[id].blank?
          self.report.cache_users[id] = {}
        end
        if self.report.cache_users[id][type].blank?
          self.report.cache_users[id][type] = []
        end

        map = self.report.cache_users[id][type]
        map << item[1] unless map.include?(item[1]) or item[1].nil?
      end
    end
  end

end