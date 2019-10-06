module Events::Request::Handler

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def receives_requests!(event, receiver_key:, name:, async: true)
      include Sidekiq::Worker

      @receiver_key = receiver_key
      @event = event
      @name = name
      @async = async

      Events::Registry.register_request self, event, async, name: name

      unless self.new.respond_to?(:perform)
        define_method :perform do |type, user: nil, user_id: nil, message: nil|
          user ||= User.find_by id: user_id if user_id.present?
          return unless user.present?

          on_request user, message
        end
      end
    end

    def async?
      @async
    end
  end

  def on_request(user, message)
    # Todo
  end

end