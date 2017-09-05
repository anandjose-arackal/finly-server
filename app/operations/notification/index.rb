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
      self.unread_count = params[:notifications].unread.count rescue 0
      self.notifications = apply_scopes(params[:notifications], params)
      self.notifications = notifications.paginate(page: params[:page], per_page: 10)
    end

  end

end
