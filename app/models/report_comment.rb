# == Schema Information
#
# Table name: report_comments
#
#  id                       :integer          not null, primary key
#  report_id                :integer          not null
#  report_comment_action_id :integer          not null
#  user_id                  :integer
#  expense_id               :integer
#  updated_field            :string(255)
#  updated_from             :text(65535)
#  updated_to               :text(65535)
#  rejected_to_id           :integer
#  content                  :text(65535)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  payment_id               :integer
#

class ReportComment < ActiveRecord::Base
  belongs_to :report
  belongs_to :user
  belongs_to :report_comment_action
  belongs_to :expense
  belongs_to :rejected_to, class_name: 'User'
  belongs_to :payment

  def generate_text(user)

  end
end
