# == Schema Information
#
# Table name: agreement_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AgreementType < ApplicationRecord
  include Seedable

  validates :name, presence: true

  def self.values
    [:privacy_policy, :terms_and_conditions, :prepaid_card_agreement, :bank_transfer_agreement]
  end

end
