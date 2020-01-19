# == Schema Information
#
# Table name: invoice_frequencies
#
#  id         :bigint           not null, primary key
#  number     :integer
#  period_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :string(36)
#

require 'rails_helper'

RSpec.describe InvoiceFrequency, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
