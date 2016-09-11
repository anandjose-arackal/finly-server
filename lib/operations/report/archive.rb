# params:
# report_id: id of report that needs to be archived

class Report::Archive < Report::Base

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank? or params.blank?
      errors << "No user or params passed."
    end
  end

  def init
    self.report = Report.find_by(id: params[:report_id])
  end

  def validate

    # check if report can be archived at all
    unless report.can_archive?
      errors << "Repoert is still not completely processed to archive it."
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
    unless report.update(archived: true)
      errors << "Couldn't archive report. PLease try again."
    end
  end

end