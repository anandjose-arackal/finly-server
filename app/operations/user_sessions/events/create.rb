class UserSessions::Events::Create < BaseOperation
  attr_accessor :session, :event, :status

  class UserSessions::Events::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :session, :event

    def init
      self.session = params[:session]
      self.event = params[:event]
    end

  end

  def pre_validate
    user_present? and params_present?
    return if has_errors?
    if RequestStoreUtil.current_session.nil?
      add_message :error, 'UserSession not found'
      return
    end
  end

  def init
    self.session = RequestStoreUtil.current_session
    self.event = self.session.events.build event_attributes
  end

  def validate
    unless self.event.valid?
      add_message :error, self.event.errors.full_messages
    end
  end

  def process
    self.event.save
  end

  def success
    UserSessions::Events::Create::SuccessPresenter.new(user, {session: self.session, event: self.event}, messages)
  end

  private

  def event_attributes
    attributes = {}
    attributes[:http_method] = RequestStoreUtil.current_request.method_symbol
    attributes[:app] = RequestStoreUtil.current_app
    attributes[:path] = RequestStoreUtil.current_request.path
    attributes[:controller] = params[:controller]
    attributes[:action] = params[:action]
    attributes[:view] = current_view
    attributes[:status_id] = RequestStoreUtil.current_session.status_id
    attributes[:message] = params[:message] || RequestStoreUtil.current_session.message
    attributes
  end

end