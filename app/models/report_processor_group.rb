# == Schema Information
#
# Table name: report_processor_groups
#
#  id                        :integer          not null, primary key
#  status_id                 :integer          not null
#  is_deleted                :boolean          default(FALSE)
#  payment_file_generated    :boolean          default(FALSE)
#  payment_file_generated_at :datetime         default(NULL)
#  scheduled_at              :date
#  completed_at              :datetime
#  total_amount_id           :integer          not null
#  processed_amount_id       :integer
#  created_by_user_id        :integer
#  source_account_id         :integer
#  source_account_type       :string(255)
#  payment_type              :string(255)
#  payment_mode              :string(255)
#  company_id                :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class ReportProcessorGroup < ActiveRecord::Base

  has_many :mappings, class_name: 'ReportProcessorGroupMapping', foreign_key: :processor_group_id, dependent: :destroy
  has_many :users, through: :mappings
  belongs_to :total_amount, class_name: 'Amount', dependent: :destroy
  belongs_to :processed_amount, class_name: 'Amount', dependent: :destroy
  belongs_to :created_by_user, class_name: 'User'
  belongs_to :status, class_name: 'ReportProcessorGroupStatus'
  belongs_to :source_account, polymorphic: true
  belongs_to :company

  validates :created_by_user_id, presence: true
  validates :status_id, presence: true

  accepts_nested_attributes_for :mappings
  accepts_nested_attributes_for :total_amount
  accepts_nested_attributes_for :processed_amount

  scope :created_bby_user, -> (user_id) { where created_by_user_id: user_id }

  delegate :scheduled?, :processing?, :processing?, :partially_completed?, :completed?, :failed?, :cancelled?, to: :status

end
