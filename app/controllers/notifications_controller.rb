class NotificationsController < ApplicationController

  def index
    @nots = []

    10.times do |x|
      noti = {
        title: "Title #{x}",
        body: "This is a body #{x}",
        read: false
      }
      @nots.push(noti)
    end
  end

  def unread
    respond_to do |format|
      format.json {render json: rand(0..10)}
    end
  end

end
