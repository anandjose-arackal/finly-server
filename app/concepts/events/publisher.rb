class Events::Publisher

  def self.publish(routing_key, message, persistence: true)
    payload = {message: message, current_user: RequestStoreUtil.current_user}
    client.publish(Events::Serializer.encode(payload).to_json, routing_key: routing_key, persistence: persistence)
  end

  def self.client
    @client ||= Sneakers::Publisher.new
  end

end