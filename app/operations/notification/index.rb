class Notification::Index < Notification::Base

  attr_accessor :notifications

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
  end

  def init

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

    def init
      self.unread_count = params[:notifications].unread.count rescue 0
      self.notifications = params[:notifications].paginate(page: params[:page], per_page: 10)
    end

  end

end
