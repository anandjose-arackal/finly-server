module Events::Consumer

  def self.included(base)
    base.include Sneakers::Worker
    # base.extend ClassMethods
  end

  # module ClassMethods
  # end

  def work(payload)
    json_payload = JSON.parse(payload) || payload

    unless json_payload.present? and (json_payload.is_a?(Hash) and json_payload.has_key?('message'))
      trigger nil, json_payload
      return
    end

    decoded_payload = Events::Serializer.decode(json_payload)
    message = decoded_payload&.dig('message') || json_payload
    user = decoded_payload&.dig('current_user')
    # Todo load request store properties
    # request_store_properties = payload&.dig('request_store_properties')
    # RequestStoreUtil.from_hash request_store_properties
    trigger user, message
    ack!
  end

  def trigger(user, message)
    self.send(:receive, user, message) if self.respond_to?(:receive)
  end

  # def receive(user, message)
  #   # Implement me
  #   ack!
  # end

end