class Event::Report::Base < Event::Base
  attr_accessor :report

  def pre_validate
    unless user.present?
      errors << 'User not found'
    end
    if params.blank? or params[:report].blank?
      errors << 'Report not found'
    end
    unless params[:report].is_a?(Report)
      errors << 'Error loading report'
    end
  end

  def init
    self.report = params[:report]
  end

end