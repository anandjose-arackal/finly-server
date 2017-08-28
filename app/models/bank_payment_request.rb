# == Schema Information
#
# Table name: bank_payment_requests
#
#  id                       :integer          not null, primary key
#  owner_id                 :integer
#  status_id                :integer
#  controlling_user_id      :integer
#  payment_order_id         :integer
#  name                     :string(255)
#  requested_amount_id      :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  submitted_at             :datetime
#  controlling_user_role_id :integer
#  description              :text(65535)

class BankPaymentRequest < ActiveRecord::Base

  belongs_to :status, class_name: "BankPaymentRequestStatus"
  belongs_to :payment_order
  belongs_to :requested_amount, class_name: "Amount"
  belongs_to :owner, class_name: "User"
  belongs_to :controlling_user, class_name: "User"
  belongs_to :controlling_user_role, class_name: "User"

  has_many :bank_payment_request_comments
  has_many :bank_payment_request_trails

  accepts_nested_attributes_for :payment_order
  accepts_nested_attributes_for :requested_amount

  # i.e. a payment request cannot exist without a payment order
  validates :payment_order, presence: true

  delegate :open?, :submitted?, :retracted?, :rejected?, :approved?, :credited?, :processing?, to: :status
  delegate :requested_amount_value, to: :requested_amount

  scope :non_owner, -> (user_id) { where.not owner_id: user_id }
  scope :with_controlling_user_role, -> (role_id) { where controlling_user_role_id: role_id }
  scope :with_user, -> (user_id) { where owner_id: user_id}
  scope :not_open, -> {where.not status_id: BankPaymentRequestStatus.id_for(:open)}
  scope :with_id, -> (id) { where id: id }

  before_save do
    self.name = generate_name
  end

  def can_submit?
    open? || retracted? || rejected?
  end

  def can_approve?
    processing?
  end

  def can_reject?
    processing?
  end

  def can_retract?
    processing?
  end

  def can_credit?
    approved?
  end

  def user
    self.owner
  end

  def initiating_account
    self.payment_order.payments.first.initiating_account
  end

  # todo - jugaad till we generalize the approval flow for
  # user manager mapping
  def controlling_for_user
    nil
  end

  alias_method :controlling_for_user_id, :controlling_for_user
  alias_method :controlling_for_user_role_id, :controlling_for_user

  private

  def generate_name
    "PR_#{self.owner.name.downcase.split.join('_')}_#{Time.now.strftime("%d.%m.%y")}"
  end
end
