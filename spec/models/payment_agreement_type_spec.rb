# == Schema Information
#
# Table name: payment_agreement_types
#
#  id         :bigint           not null, primary key
#  name       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

require 'rails_helper'

RSpec.describe PaymentAgreementType, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
