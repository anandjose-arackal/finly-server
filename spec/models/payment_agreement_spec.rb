# == Schema Information
#
# Table name: payment_agreements
#
#  id                    :bigint           not null, primary key
#  order_number          :string(255)
#  title                 :string(255)
#  policy_id             :integer
#  agreement_date        :datetime
#  execution_date        :datetime
#  expiration_date       :datetime
#  renewal_date          :datetime
#  note                  :text(65535)
#  no_expiration         :boolean          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  creator_id            :integer
#  controlling_level_id  :integer
#  status_id             :integer
#  submitted_at          :datetime
#  approved_at           :datetime
#  reject_note           :text(65535)
#  company_id            :integer
#  renewal_reminder_date :datetime
#  total_amount_id       :integer
#  override_order_number :string(255)
#  terminated_at         :datetime
#  terminated_by_id      :integer
#  termination_reason    :text(65535)
#  deleted_at            :datetime
#

require 'rails_helper'

RSpec.describe PaymentAgreement, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
