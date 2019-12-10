# == Schema Information
#
# Table name: transfer_modes
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string(255)
#

class TransferMode < ApplicationRecord
	include Seedable

  def self.values
    [:imps, :rtgs, :neft]
  end

  def imps?
    self.id == TransferMode.id_for(:imps)
  end

  def rtgs?
    self.id == TransferMode.id_for(:rtgs)
  end

  def neft?
    self.id == TransferMode.id_for(:neft)
  end

  # these modes will not be allowed to be deleted in a company configuration
  def self.common_modes
  	[
  		TransferMode.id_for(:imps),
  		TransferMode.id_for(:rtgs),
  		TransferMode.id_for(:neft)
  	]
  end

end
