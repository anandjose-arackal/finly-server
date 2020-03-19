# == Schema Information
#
# Table name: payment_agreement_escalations
#
#  id                   :bigint           not null, primary key
#  period_id            :integer
#  number               :integer
#  percentage_increment :decimal(10, )
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  invoice_id           :integer
#  start_date           :datetime
#  end_date             :datetime
#  revised_amount_id    :integer
#  deleted_at           :datetime
#

require 'rails_helper'

RSpec.describe PaymentAgreementEscalation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
