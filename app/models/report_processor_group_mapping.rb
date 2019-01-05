# == Schema Information
#
# Table name: report_processor_group_mappings
#
#  id                         :integer          not null, primary key
#  processor_group_id         :integer          not null
#  user_id                    :integer          not null
#  processor_accountable_id   :integer
#  processor_accountable_type :string(255)
#  amount_id                  :integer          not null
#  completed_at               :datetime
#  marked_as_completed        :boolean          default(FALSE)
#  status_id                  :integer          not null
#  payment_id                 :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  note                       :text(65535)
#  marked_as_closed           :boolean
#

class ReportProcessorGroupMapping < ApplicationRecord

  belongs_to :user, optional: true
  belongs_to :amount, optional: true, dependent: :destroy
  belongs_to :processor_group, optional: true, class_name: 'ReportProcessorGroup'
  belongs_to :processor_accountable, optional: true, polymorphic: true
  belongs_to :status, optional: true, class_name: 'ReportProcessorGroupStatus'
  belongs_to :payment, optional: true

  has_many :reports
  has_many :system_messages, as: :messagable, dependent: :destroy

  validates :user_id, presence: true
  validates :status_id, presence: true

  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :reports
  accepts_nested_attributes_for :system_messages

  scope :with_id, -> (id) { where id: id }
  scope :with_processor_group_id, -> (group_id) { where processor_group_id: group_id }
  scope :with_user_id, -> (user_id) { where user_id: user_id }
  scope :pending, -> { where status_id: ReportProcessorGroupStatus.id_for(:pending) }
  scope :not_completed, -> { where.not status_id: ReportProcessorGroupStatus.id_for(:completed) }
  scope :include_for_payment_file, -> { includes :user, :amount, :processor_accountable }
  scope :sum_amounts, -> { joins(:amount).sum(:INR) }
  scope :pluck_group_id, -> { pluck(:processor_group_id) }

  before_destroy do
    self.reports.update_all(report_processor_group_mapping_id: nil)
  end

end
