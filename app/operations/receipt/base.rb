class Receipt::Base < BaseOperation

  def authorized_user_types
    [:employee]
  end
  
end