class User::PrepaidCard::Base < BaseOperation
  attr_accessor :selected_user

  def pre_validate
    if user.blank? or params.blank? or (params[:id].blank? and params[:user_id].blank?)
      messages[:error] << 'User not found'
    end
  end

  def init
    selected_user_id = (params[:id] or params[:user_id])
    if personal_view? or selected_user_id == user.id
      self.selected_user = user
    else
      operation = User::Team::Index.new(user, params)
      result = operation.run
      if operation.success?
        self.selected_user = result.with_id(selected_user_id).first rescue nil
        messages[:error] << 'User not found' if self.selected_user.blank?
      else
        messages[:error] = operation.messages[:error]
      end
    end
  end

  def validate
    if selected_user.blank?
      messages[:error] << 'User not found'
      return
    end
    if selected_user.cards.blank?
      messages[:error] << 'Card has not been assigned to the user'
    end
  end

end