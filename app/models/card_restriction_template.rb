# == Schema Information
#
# Table name: card_restriction_templates
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CardRestrictionTemplate < ActiveRecord::Base

  has_one :card_restriction

  validates :name, presence: true

end
