# action to destroy the report.
# params:
# report_id: id of the report that needs to be destroyed

class Report::Destroy < Report::Base

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, 'User not found'
    end
    if params.blank?
      add_message :error, 'Report not found'
    end
  end

  def validate
    # check if the report can be destroyed at all
    unless report.can_destroy?
      add_message :error, "Report can only be deleted once it's retracted or rejected."
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
      add_message :error, report.errors.full_messages
      return false
    end
  end

  def post_process
    add_message :success, 'Report deleted'
  end

end