# == Schema Information
#
# Table name: card_load_request_comment_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CardLoadRequestCommentAction < ActiveRecord::Base

  def self.create_id
    1
  end

  def self.retract_id
    2
  end

  def self.submit_id
    3
  end

  def self.approve_id
    4
  end

  def self.reject_id
    5
  end

  def self.unapprove_id
    6
  end

  def self.take_control_id
    7
  end

  def self.comment_id
    8
  end

  def self.update_id
    9
  end

end
