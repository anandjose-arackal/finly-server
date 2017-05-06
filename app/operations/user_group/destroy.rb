class UserGroup::Destroy < UserGroup::Base

  def process
    unless self.user_group.destroy
      add_message :error, self.user_group.errors.full_messages
      return
    end
  end

end