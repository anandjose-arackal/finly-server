# == Schema Information
#
# Table name: company_funds_load_request_types
#
#  id   :integer          not null, primary key
#  name :string(255)
#  uuid :string(36)
#

class CompanyFundsLoadRequestType < ApplicationRecord
  include Seedable

  def self.values
    [:itzcash, :yesbank]
  end
end
