class CustomField::Configuration::ValidateFieldValue < CustomField::Configuration::Base
  attr_accessor :type_id, :value
  
  def self.call(params)
    self.new(params).run
  end
  
  def initialize(params)
    super(nil, params)
  end

  def pre_validate
    if params.blank?
      add_message :error, 'Nothing to add'
    end
  end

  def pre_authorize

  end

  def init

  end

  def authorize

  end

  def validate

  end

  def process

  end

end