class Statement::Show < Statement::Base

  attr_accessor :items

  def pre_validate

  end

  def init
    load_selected_user
  end

end