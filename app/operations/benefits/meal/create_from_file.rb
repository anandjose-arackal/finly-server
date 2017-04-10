class Benefits::Meal::CreateFromFile < Benefits::Meal::Base

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:file].blank?
      add_message :error, 'Error loading file. File not uploaded correctly'
      return
    end
    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate the transfer'
      return
    end
  end

  def init
    self.file = params[:file]
  end

  def validate

  end

  def process

  end

end