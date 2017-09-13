class Notification::Index < Notification::Base

  attr_accessor :notifications

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
  end

  def init
    params[:with_application] = RequestStore.store[:current_app].to_s
  end

  def process
    self.notifications = user.notifications
  end

  def success
    params[:notifications] = notifications
    Notification::Index::NotificationsPresenter.new(user, params, messages)
  end

  class Notification::Index::NotificationsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :notifications, :unread_count

    has_scope :with_application

    def init
      self.notifications = apply_scopes(params[:notifications], params)
      self.unread_count = notifications.unread.count rescue 0
      self.notifications = notifications.paginate(page: params[:page], per_page: 10)
    end

  end

end
