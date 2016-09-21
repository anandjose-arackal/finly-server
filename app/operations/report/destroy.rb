# action to destroy the report.
# params:
# report_id: id of the report that needs to be destroyed

class Report::Destroy < Report::Base

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "User or params not passed."
    end
  end

  def validate
    # check if the report can be destroyed at all
    unless report.can_destroy?
      messages[:error] << "Report can only be deleted once it's retracted or rejected."
    end
  end

  def authorize
    unless report
      raise_unauthorized_exception
    end
    unless report.user_id == user.id
      raise_unauthorized_exception
    end
  end

  def process
    unless report.destroy
      messages[:error] << report.errors.full_messages
      return false
    end
  end

  def post_process
    messages[:success] << "Report destroyed."
  end

end