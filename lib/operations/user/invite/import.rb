class User::Invite::Import < BaseOperation

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] = "No user or params passed."
    end
  end


end