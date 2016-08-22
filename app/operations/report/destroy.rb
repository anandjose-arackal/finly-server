# action to destroy the report.
# params:
# report_id: id of the report that needs to be destroyed

class Report::Destroy < Report::Base

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank? or params.blank?
      errors << "User or params not passed."
    end
  end

  def init
    self.report = Report.find_by(id: params[:report_id])
  end

  def validate
    unless report
      errors << "Report not found."
    end

    # check if the report can be destroyed at all
    unless report.can_destroy?
      errors << "Report can only be deleted once it's retracted or rejected."
    end
  end

  def authorize
    unless report.user_id == user.id
      errors << "You do not own this report."
    end
  end

  def process
    unless report.destroy
      errors << report.errors.full_messages
      return false
    end
  end

  def retrieve
    if is_success?
      return true
    else
      return false
    end
  end
end