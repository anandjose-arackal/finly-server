class UserAgentClients::FindOrCreate < BaseOperation

  class UserAgentClients::FindOrCreate::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :user_agent_client

    def init
      self.user_agent_client = params[:user_agent_client]
    end

  end

  attr_accessor :user_agent_client

  def pre_validate
    user_present?
  end

  def process
    self.user_agent_client = user_agent_from_request
  end

  def success
    UserAgentClients::FindOrCreate::SuccessPresenter.new(user, {user_agent_client: user_agent_client}, messages)
  end

  protected

  def user_agent_from_request
    request = RequestStoreUtil.current_request
    ua_string = request.user_agent
    return if ua_string.nil?

    user_agent = user.user_agent_clients.find_by_user_agent(ua_string)
    return user_agent if user_agent.present?

    user_agent = user.user_agent_clients.build user_agent: ua_string, status_id: UserAgentClientStatus.id_for(:unverified)
    unless user_agent.valid?
      add_message :error, user_agent.errors.full_messages
      return
    end
    user_agent.save
    user_agent
  end

end