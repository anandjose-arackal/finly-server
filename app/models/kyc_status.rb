class KycStatus < ActiveRecord::Base
  include Seedable

  def self.values
    [:incomplete, :pending, :error, :approved]
  end

end
