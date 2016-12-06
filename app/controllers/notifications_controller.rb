class NotificationsController < ApplicationController

  def index
    @nots = []

    10.times do |x|
      noti = {
        title: "Title #{x} - #{rand(0..99)}",
        body: "This is a body #{x}   #{rand(0..99)}",
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

  def mark_all_read
    @result = {:success => true}
    respond_to do |format|
      format.json { render json: @result.as_json }
    end
  end

end
