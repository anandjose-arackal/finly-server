# == Schema Information
#
# Table name: currencies
#
#  id           :integer          not null, primary key
#  country      :string(255)
#  country_code :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Currency < ActiveRecord::Base
  has_many :amounts

  def self.default_currency_id
    1
  end
end
