# == Schema Information
#
# Table name: payment_agreement_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe PaymentAgreementStatus, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
