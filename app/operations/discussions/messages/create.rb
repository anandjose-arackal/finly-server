class Discussions::Messages::Create < BaseOperation

  def pre_validate
    user_present? and params_present?
  end

  def init
    master = master_from_params
    master.verify
  end

  def validate

  end

  def process

  end

  protected
  def master_from_params
    
  end

end