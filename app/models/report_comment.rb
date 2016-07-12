class ReportComment < ActiveRecord::Base
  belongs_to :report
  belongs_to :user
  belongs_to :report_comment_action
  belongs_to :expense
  belongs_to :rejected_to, class_name: 'User'

  def generate_text(user)

  end
end
