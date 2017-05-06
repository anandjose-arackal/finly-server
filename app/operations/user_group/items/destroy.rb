class UserGroup::Items::Destroy < UserGroup::Items::Base

  def process
    unless self.user_group_item.destroy
      add_message :error, self.user_group_item.errors.full_messages
    end
  end

end