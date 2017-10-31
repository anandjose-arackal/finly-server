# == Schema Information
#
# Table name: report_processor_group_mappings
#
#  id                         :integer          not null, primary key
#  processor_group_id         :integer          not null
#  user_id                    :integer          not null
#  processor_accountable_id   :integer          not null
#  processor_accountable_type :string(255)      not null
#  amount_id                  :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class ReportProcessorGroupMapping < ActiveRecord::Base

  belongs_to :user
  belongs_to :amount, dependent: :destroy
  belongs_to :processor_group, class_name: 'ReportProcessorGroup'
  belongs_to :processor_accountable, polymorphic: true

  has_many :reports

  validates :user_id, presence: true

  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :reports

  before_destroy do
    self.reports.update_all(report_processor_group_mapping_id: nil)
  end

end
