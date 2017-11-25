# == Schema Information
#
# Table name: money_request_processor_mappings
#
#  id                         :integer          not null, primary key
#  processor_id               :integer          not null
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
#

class MoneyRequestProcessorMapping < ActiveRecord::Base

  belongs_to :user
  belongs_to :amount, dependent: :destroy
  belongs_to :processor_group, class_name: 'ReportProcessorGroup'
  belongs_to :processor_accountable, polymorphic: true
  belongs_to :status, class_name: 'ReportProcessorGroupStatus'
  belongs_to :payment

  has_many :money_requests
  has_many :system_messages, as: :messagable, dependent: :destroy

  validates :user_id, presence: true
  validates :status_id, presence: true

  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :money_requests
  accepts_nested_attributes_for :system_messages

  scope :with_processor_id, -> (group_id){ where processor_id: group_id }
  scope :pending, -> { where status_id: MoneyRequestProcessorStatus.id_for(:pending) }
  scope :not_completed, -> { where.not status_id: MoneyRequestProcessorStatus.id_for(:completed) }
  scope :include_for_payment_file, -> { includes :user, :amount, :processor_accountable }

  before_destroy do
    self.money_requests.update_all(money_request_processor_mapping_id: nil)
  end

end
