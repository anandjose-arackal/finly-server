class Settlement::SReport::Processing::Update < Settlement::SReport::Processing::Base

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    
  end

  def init

  end

  def validate

  end

  def process

  end

end