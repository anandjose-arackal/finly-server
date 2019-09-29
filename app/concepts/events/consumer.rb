module Events::Consumer

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def consumes_event!(key, opts={})
      include Sneakers::Worker unless self.respond_to?(:from_queue)
      unless key == NoObject
        @event = key
        @event_options = opts
        from_queue key, opts
      end
      @consumes_event = true
      @event
    end

    def consumes_event?
      !!@consumes_event
    end
  end

  def work(payload)
    json_payload = JSON.parse(payload) || payload

    unless json_payload.present? and (json_payload.is_a?(Hash) and json_payload.has_key?('message'))
      trigger nil, json_payload
      return
    end

    json_payload = json_payload.to_h.with_indifferent_access

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
    self.send(:on_event, user, message) if self.respond_to?(:on_event)
  end

  # def on_event(user, message)
  #   # Implement me
  #   ack!
  # end

end