class NotificationsController < ApplicationController

  def index
    @notifications = current_user.notifications
    # @nots = []
    #
    # 10.times do |x|
    #   noti = {
    #     title: "Title #{x} - #{rand(0..99)}",
    #     body: "This is a body #{x}   #{rand(0..99)}",
    #     read: false
    #   }
    #   @nots.push(noti)
    # end
  end

  def unread
    # returns the unread notifications of the current user
    @unread = current_user.notifications.unread.count rescue 0
    respond_to do |format|
      format.json {render json: @unread}
    end
  end

  def mark_all_read
    @result = {:success => true}
    respond_to do |format|
      format.json { render json: @result.as_json }
    end
  end

end
