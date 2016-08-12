# == Schema Information
#
# Table name: cards
#
#  id            :integer          not null, primary key
#  ending_number :string(255)
#  proxy         :string(255)
#  card_type_id  :integer
#  description   :text(65535)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Card < ActiveRecord::Base
  belongs_to :card_type

end
