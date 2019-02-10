class UserSessions::Events::Create < BaseOperation

  def self.call(session, params)
    self.new(session, params).run
  end

  def initialize(session, params)
    super(nil, params)
    self.session = session
  end

  def pre_validate

  end

  def process

  end

end