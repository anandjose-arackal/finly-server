class BackgroundOperation < BaseOperation
  include Sidekiq::Worker

  def self.call(user, params)
    user_id = user
    if user.present? and user.is_a?(User)
      user_id = user.id
    end
    self.new.perform(user_id, params)
  end

  def self.call_async(user_id, params)
    self.perform_async(user_id, params)
  end

  def self.perform_async(user_id, params)
    if user_id.present? and user_id.is_a?(User)
      user_id = user.id
    end
    # this calls the super method of Sidekiq::Worker which calls the perfoem method
    super(user_id, params)
  end

  def initialize
    clear_messages
  end

  def perform(user_id, params)
    if params.present? and params.is_a?(Hash)
      params = params.with_indifferent_access
    end
    self.user = User.find_by_id(user_id)
    self.params = params
    self.run.messages
  end

end