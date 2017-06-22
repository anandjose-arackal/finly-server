class AgreementType < ActiveRecord::Base
  include Seedable

  validates :name, presence: true

  def self.values
    [:privacy_policy, :terms_and_conditions, :prepaid_card_agreement]
  end

end
