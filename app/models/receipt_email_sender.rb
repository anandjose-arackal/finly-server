# == Schema Information
#
# Table name: receipt_email_senders
#
#  id                        :integer          not null, primary key
#  email_id                  :string(255)      not null
#  receipt_email_template_id :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  domain                    :string(255)      not null
#  search_term               :string(255)      not null
#

class ReceiptEmailSender < ActiveRecord::Base
  belongs_to :receipt_email_template

  scope :having_email_id, -> (email_id) { find_by email_id: email_id }
  scope :pluck_email_id, -> { pluck(:email_id) }

  validates :email_id, presence: true, uniqueness: true
  validates :receipt_email_template_id, presence: true
end
