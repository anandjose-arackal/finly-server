class NotificationsController < BaseControllers::WebBase



  def index
    @result = Notification::Index.(current_user, params)
  end

  def unread
    # calls notifications index itself because it's the same sql query
    @result = Notification::Index.(current_user, params)
    if @result.success?
      respond_to do |format|
        format.json {render json: @result.unread_count}
      end
    else
      respond response: :failure
    end
  end

  def mark_all_read
    @result = Notification::MarkAllRead.(current_user, params)
    respond_to do |format|
      format.json { render json: @result.as_json }
    end
  end

end
