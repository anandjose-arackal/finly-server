class AnalyticsDashboard < ApplicationRecord
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :company, optional: true
  belongs_to :system_dashboard, optional: true

  serialize :reports, JSON

  def as_json(options={})
    {
        id: id,
        name: name,
        description: description,
        default: !!default,
        reports: reports
    }
  end

end
