class Admin::Cards::Assign::Index < Admin::Cards::Assign::Base
  attr_accessor :cards

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init

  end

end