# == Schema Information
#
# Table name: receipt_email_templates
#
#  id                  :integer          not null, primary key
#  name                :string(255)      not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  default_currency_id :integer          not null
#

class ReceiptEmailTemplate < ActiveRecord::Base
  has_many :receipt_email_senders, dependent: :destroy
  has_many :receipt_email_data_points, dependent: :destroy

  belongs_to :default_currency, class_name: 'Currency'

  validates :default_currency_id, presence: true
end
