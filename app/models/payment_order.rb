# == Schema Information
#
# Table name: payment_orders
#
#  id                        :integer          not null, primary key
#  payment_order_type_id     :integer          not null
#  scheduled_at              :date
#  processed_at              :datetime
#  initiating_user_id        :integer          not null
#  payment_order_status_id   :integer          not null
#  payment_file_file_name    :string(255)
#  payment_file_content_type :string(255)
#  payment_file_file_size    :integer
#  payment_file_updated_at   :datetime
#  company_id                :integer          not null
#  amount_requested_id       :integer
#  amount_processed_id       :integer
#  note                      :text(65535)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class PaymentOrder < ActiveRecord::Base

  CONFIG = {
    meal_card: {
      subscription: :meal_card_enabled,
      card_program_id: CardProgram.id_for(:meal),
      payment_type_id: PaymentType.id_for(:credit_meal_card),
      payment_order_type_id: PaymentOrderType.id_for(:meal_card)
    },
    medical_card: {subscription: :medical_card_enabled,
      card_program_id: CardProgram.id_for(:medical),
      payment_type_id: PaymentType.id_for(:credit_medical_card),
      payment_order_type_id: PaymentOrderType.id_for(:medical_card)
    },
    expense_card: {subscription: :expense_card_enabled,
      card_program_id: CardProgram.id_for(:expense),
      payment_type_id: PaymentType.id_for(:credit_expense_card),
      payment_order_type_id: PaymentOrderType.id_for(:expense_card)
    },
    reimbursement_card: {subscription: :reimbursement_card_enabled,
      card_program_id: CardProgram.id_for(:reimbursement),
      payment_type_id: PaymentType.id_for(:credit_reimbursement_card),
      payment_order_type_id: PaymentOrderType.id_for(:reimbursement_card)
    }
  }

  belongs_to :payment_order_type
  belongs_to :payment_order_status
  belongs_to :company
  belongs_to :amount_requested, class_name: 'Amount'
  belongs_to :amount_processed, class_name: 'Amount'
  belongs_to :initiating_user, class_name: 'User'

  has_many :payments, dependent: :destroy

  has_attached_file :payment_file, default_url: '/images/:style/missing.png'
  validates_attachment_content_type :payment_file,
                                    content_type: %w(application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet text/csv)

  validates :payment_order_type_id, presence: true
  validates :initiating_user_id, presence: true
  validates :payment_order_status_id, presence: true
  validates :company_id, presence: true

  accepts_nested_attributes_for :amount_requested
  accepts_nested_attributes_for :amount_processed
  accepts_nested_attributes_for :payments

  scope :with_type_id, -> (id) { where payment_order_type_id: id }
  scope :with_id, -> (id) { where id: id }
  scope :with_status, ->(status_id) { where payment_order_status_id: status_id }
  scope :scheduled, -> { with_status(PaymentOrderStatus.id_for(:scheduled)) }
  scope :scheduled_on_or_before, -> (date) { where 'scheduled_at <= ?', date }
  scope :joins_amount_requested, -> { joins :amount_requested }
  scope :total_amount_requested, -> { joins_amount_requested.sum(:value) }

  delegate :cancelled?, :completed?, :failed?, :pending?, :in_progress?, :scheduled?, :partially_completed?, to: :payment_order_status

  default_scope { order(created_at: :desc) }

  # method for total of all the payments in this particular payment order
  def request_total
    self.payments.joins(:amount).sum(:value)
  end

end
