# == Schema Information
#
# Table name: payment_trails
#
#  id                      :integer          not null, primary key
#  date                    :date
#  initiating_account_id   :integer
#  receiving_account_id    :integer
#  initiating_account_type :string(255)
#  receiving_account_type  :string(255)
#  payment_status_id       :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  payment_id              :integer
#  initiating_user_id      :integer
#  initiating_user_type    :string(255)
#  receiving_user_id       :integer
#  receiving_user_type     :string(255)
#

class PaymentTrail < ApplicationRecord

  belongs_to :initiating_account, optional: true, polymorphic: true
  belongs_to :receiving_account, optional: true, polymorphic: true

  belongs_to :initiating_user, optional: true, polymorphic: true
  belongs_to :receiving_user, optional: true, polymorphic: true

  belongs_to :payment_purpose, optional: true
end
