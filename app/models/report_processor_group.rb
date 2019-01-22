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
#  created_by_user_role_id   :integer
#  source_account_id         :integer
#  source_account_type       :string(255)
#  marked_as_completed       :boolean          default(FALSE)
#  payment_type              :string(255)
#  payment_mode              :string(255)
#  company_id                :integer          not null
#  payment_order_id          :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  marked_as_closed          :boolean
#  tally_exported            :boolean          default(FALSE)
#

class ReportProcessorGroup < ApplicationRecord

  has_many :mappings, class_name: 'ReportProcessorGroupMapping', foreign_key: :processor_group_id, dependent: :destroy
  has_many :users, through: :mappings
  belongs_to :total_amount, optional: true, class_name: 'Amount', dependent: :destroy
  belongs_to :processed_amount, optional: true, class_name: 'Amount', dependent: :destroy
  belongs_to :created_by_user, optional: true, class_name: 'User'
  belongs_to :status, optional: true, class_name: 'ReportProcessorGroupStatus'
  belongs_to :source_account, optional: true, polymorphic: true
  belongs_to :company, optional: true
  belongs_to :payment_order, optional: true

  validates :created_by_user_id, presence: true
  validates :status_id, presence: true

  accepts_nested_attributes_for :mappings
  accepts_nested_attributes_for :total_amount
  accepts_nested_attributes_for :processed_amount

  scope :with_id, -> (id) { where id: id }
  scope :created_by_user, -> (user_id) { where created_by_user_id: user_id }
  scope :with_payment_order_id, -> (payment_order_id) { where payment_order_id: payment_order_id }
  scope :include_mapping_reports, -> { includes({mappings: [:reports, :system_messages]}) }
  scope :include_for_show, -> {
    includes(
        {mappings:
             [:user,
              {amount: [:currency]},
              :status,
              :payment,
              :reports,
              :system_messages]
        },
        {total_amount: [:currency]},
        {processed_amount: [:currency]},
        :status,
        :created_by_user)
  }
  scope :pluck_status_id, -> { pluck :status_id }
  scope :not_completed, -> { where status_id: ReportProcessorGroupStatus.ids_for([:pending, :scheduled,
                                                                                  :processing, :partially_completed,
                                                                                  :failed]) }
  scope :completed, -> { where status_id: ReportProcessorGroupStatus.id_for(:completed) }
  scope :filter_user_id, -> (user_id) {
    id = pluck(:id)
    filter_ids = ReportProcessorGroupMapping.with_processor_group_id(id).with_user_id(user_id).pluck(:processor_group_id)
    with_id(filter_ids)
  }
  # From here
  scope :filter_search, -> (search_key) {
    if search_key.present?
      id = pluck(:id)
      mapping_ids = ReportProcessorGroupMapping.with_processor_group_id(id).pluck(:id)
      filtered_mapping_id = Report.filter_mapping_id(mapping_ids).filter_search(search_key).pluck_mapping_id
      filtered_ids = ReportProcessorGroupMapping.with_id(filtered_mapping_id).pluck_group_id
      with_id(filtered_ids)
    end
  }
  scope :filter_created_by_user_id, -> (user_id) { where created_by_user_id: user_id }
  scope :payment_mode, -> (payment_mode) { where payment_mode: payment_mode }
  scope :filter_payment_type, -> (payment_type) { where payment_type: payment_type }
  scope :filter_date, ->(date_from = nil, date_to = nil) do
    # sample params: filter_date[expense, 2016-03-01, 2016-03-20]
    unless date_from.blank? && date_to.blank?
      date_from = "1990-01-01" if date_from.blank?
      date_to = "2100-01-01" if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date + 1 if date_to.present?
      # date_to = DateUtils.local_date if date_to.blank?
      report_groups = arel_table
      where(report_groups[:created_at].gteq(date_from).and(report_groups[:created_at].lteq(date_to)))
    end
  end
  scope :filter_scheduled_date, ->(date_from = nil, date_to = nil) do
    # sample params: filter_date[expense, 2016-03-01, 2016-03-20]
    unless date_from.blank? && date_to.blank?
      date_from = "1990-01-01" if date_from.blank?
      date_to = "2100-01-01" if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date + 1 if date_to.present?
      # date_to = DateUtils.local_date if date_to.blank?
      report_groups = arel_table
      where(report_groups[:scheduled_at].gteq(date_from).and(report_groups[:scheduled_at].lteq(date_to)))
    end
  end
  scope :filter_completed_date, ->(date_from = nil, date_to = nil) do
    # sample params: filter_date[expense, 2016-03-01, 2016-03-20]
    unless date_from.blank? && date_to.blank?
      date_from = "1990-01-01" if date_from.blank?
      date_to = "2100-01-01" if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date + 1 if date_to.present?
      # date_to = DateUtils.local_date if date_to.blank?
      report_groups = arel_table
      where(report_groups[:completed_at].gteq(date_from).and(report_groups[:completed_at].lteq(date_to)))
    end
  end
  # to here

  default_scope { order created_at: :desc }

  delegate :scheduled?, :pending?, :processing?, :partially_completed?, :completed?, :failed?, :cancelled?, to: :status

  before_destroy do
    if payment_order.present?
      if [PaymentOrderStatus.id_for(:scheduled)].include? payment_order.payment_order_status_id
        payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:cancelled))
        payment_order.payments.pending.update_all(payment_status_id: PaymentStatus.id_for(:cancelled))
      end
    end
  end

  def process_outside_finly?
    outside_finly? || payment_file?
  end

  def process_via_finly?
    bank_transfer? || reimbursement_card?
  end

  def bank_transfer?
    payment_type == 'bank_transfer'
  end

  def reimbursement_card?
    payment_type == 'reimbursement_card'
  end

  def outside_finly?
    payment_type == 'outside_finly'
  end

  def payment_file?
    payment_type == 'payment_file'
  end

  def mark_as_closed?
    payment_type == 'mark_as_closed'
  end

end
