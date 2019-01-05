# params = {money_request: request_obj, user_before: user_object}
# Note: the request object caches users roles. So if you call Reports::ActionUserRole by passing the same object, it responds without running any queries.

class MoneyRequests::AssociatedUsers < MoneyRequests::Base
  attr_accessor :associated_users, :tracks, :user_before

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
    end
    if params.blank? or (params[:id].blank? and params[:money_request_id].blank? and params[:money_request].blank?)
      add_message :error, 'Money Request not found'
    end
  end

  def init
    self.money_request = params[:money_request]
    super if self.money_request.blank?
    if self.money_request.present?
      self.tracks = money_request.tracks
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
    if self.money_request.controlling_user_id.present? and (user_before.blank? or user_before.id != self.money_request.controlling_user_id)
      if self.money_request.controlling_for_user_id.present?
        user_ids << self.money_request.controlling_for_user_id
      else
        user_ids << self.money_request.controlling_user_id
      end
    end

    # User IDs was blank when an admin was taking control of his own money_request and rejecting it. This is the fix
    if user_ids.present?
      user_ids.uniq!
    else
      user_ids = [self.user.id]
    end
    user_ids
  end

  def cache_user_roles(tracking, type)
    return if tracking.blank?
    # Load money_request Cache from tracking
    self.money_request.cache_users = {} if self.money_request.cache_users.blank?
    tracking.each do |track|
      [[track.action_user_id, track.action_user_role_id], [track.modified_user_id, track.modified_user_role_id]].each do |item|

        id = item[0]
        if self.money_request.cache_users[id].blank?
          self.money_request.cache_users[id] = {}
        end
        if self.money_request.cache_users[id][type].blank?
          self.money_request.cache_users[id][type] = []
        end

        map = self.money_request.cache_users[id][type]
        map << item[1] unless map.include?(item[1]) or item[1].nil?
      end
    end
  end

end