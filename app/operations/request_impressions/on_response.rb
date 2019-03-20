class RequestImpressions::OnResponse < BaseOperation
  attr_accessor :duration, :response

  def self.call(duration, response)
    self.new(duration, response).run
  end

  def initialize(duration, response)
    self.duration = duration
    self.response = response
  end

  def pre_validate
    if RequestStoreUtil.request_impression.blank?
      add_message :error, 'Request Impression has not been set'
    end
  end

  def process
    blocked = params[:rack_attack_block]
    blocked_by = nil
    block_reason = params[:block_reason]
    if blocked
      blocked_by = :rack_attack
    else
      user_session = RequestStoreUtil.current_session
      if UserSessionStatus.ids_for(:revoked, :blocked, :failed, :expired).include?(user_session.status_id)
        blocked = true
        blocked_by = :gatekeeper
        block_reason = user_session.message
      end
    end

    RequestStoreUtil.request_impression.update(
        {
            response_time: self.duration,
            response_status: self.response&.status,
            user_id: RequestStoreUtil.current_user&.id,
            company_id: RequestStoreUtil.current_company&.id,
            app: RequestStoreUtil.current_app,
            view: RequestStoreUtil.current_view,
            blocked: blocked,
            blocked_by: blocked_by,
            block_reason: block_reason,
            user_session_id: RequestStoreUtil.current_session&.id,
            access_token_id: RequestStoreUtil.current_session&.access_token_id,
            user_device_id: RequestStoreUtil.current_session&.user_device_id,
            user_ip_id: RequestStoreUtil.current_session&.user_ip_id
        }
    )
  end

end