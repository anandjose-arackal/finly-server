class Policy::Show < Policy::Base

  def pre_validate
    if user.blank? or params.blank?
      errors << "No user or policy params passed."
    end
  end


end