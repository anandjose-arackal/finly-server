class BankTransfer::PaymentRequest::ActionUserRole < BankTransfer::PaymentRequest::Base

  attr_accessor :selected_user_id, :roles, :user_before, :bank_payment_request

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
    end
    if params.blank? or (params[:id].blank? and params[:bank_payment_request_id].blank? and params[:bank_payment_request].blank?)
      add_message :error, 'Payment Order not found'
    end
  end

  def init
    self.roles = []
    self.bank_payment_request = params[:bank_payment_request]
    super if self.bank_payment_request.blank?
    self.user_before = params[:user_before]
    self.selected_user_id = (params[:user_id] or params[:selected_user_id])
    if self.selected_user_id.blank? and params[:user].present? or params[:selected_user].present?
      selected_user = (params[:user] or params[:selected_user])
      self.selected_user_id = selected_user.id
    end
  end

  def authorize
    unless self.bank_payment_request.present?
      raise_unauthorized_exception
    end
  end

  def validate
    if selected_user_id.blank?
      add_message :error, 'User not found'
    end
  end

  def process
    # Cache is loaded when associated users is called. Note: If associated_users is called with user_before, the same values are going to be held in the cache

    return if load_from_cache

    tracking = self.bank_payment_request.trails
    if self.user_before.present?
      track = tracking.find_by(action_user_id: user_before.id)
      unless track.blank?
        tracking = tracking.created_before(track.created_at)
      end
    end

    tracking = tracking.involving_user(self.selected_user_id)

    tracking.each do |track|
      [[track.action_user_id, track.action_user_role_id], [track.modified_user_id, track.modified_user_role_id]].each do |item|
        self.roles << item[1] unless item[0] != self.selected_user_id or self.roles.include?(item[1]) or item[1].nil?
      end
    end
  end

  def success
    (self.roles or [])
  end

  protected
  def load_from_cache
    cache = bank_payment_request.cache_users
    if cache.present? and cache[selected_user_id].present? and bank_payment_request.cache_users[selected_user_id][:interacted_roles].present?
      self.roles = bank_payment_request.cache_users[selected_user_id][:interacted_roles]
      return true
    end
    false
  end
end