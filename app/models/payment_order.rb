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
#  amount_requested_id       :integer          not null
#  amount_processed_id       :integer          not null
#  note                      :text(65535)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class PaymentOrder < ActiveRecord::Base
  belongs_to :payment_order_type
  belongs_to :payment_order_status
  belongs_to :company

  has_many :payments

  has_attached_file :payment_file, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :payment_file, content_type: %w(application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet text/csv)

  validates :payment_order_type_id, presence: true
  validates :initiating_user_id, presence: true
  validates :payment_order_status_id, presence: true
  validates :company_id, presence: true
  validates :amount_requested_id, presence: true
  validates :amount_processed_id, presence: true

end
