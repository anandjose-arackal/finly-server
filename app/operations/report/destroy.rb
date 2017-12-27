# action to destroy the report.
# params:
# report_id: id of the report that needs to be destroyed

class Report::Destroy < Report::Base
  attr_accessor :reports

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

  def init
    id = (params[:id] or params[:report_id])
    self.reports = Report::Index.(user, params).reports.with_id(id)
  end

  def validate
    unless self.reports.present?
      add_message :error, 'Nothing to delete'
      return
    end
    if self.reports.without_user(user.id).present?
      add_message :error, "The list contains items that cannot be deleted"
      return
    end
    # check if the report can be destroyed at all
    self.reports.each do |report|
      unless report.can_destroy?
        add_message :error, "Report can only be deleted once it's retracted or rejected."
        return
      end
    end
  end

  def authorize

  end

  def process
    self.reports.each do |report|
      unless report.destroy
        add_message :error, report.errors.full_messages
        return false
      end
    end
  end

  def post_process
    add_message :success, 'Report deleted'
  end

end