class  Agreements::AgreementAuthorizer::Base < BaseOperation
  def initialize(params={})
    clear_messages
    self.params = (ActionController::Parameters.new(params) or {})
  end

  def init
  end

  def self.call(params={})
    self.new(params).run
  end

  def validate
  end

  def process
  end

end