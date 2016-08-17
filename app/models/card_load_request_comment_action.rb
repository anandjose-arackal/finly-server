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

  def create_id
    1
  end

  def retract_id
    2
  end

  def submit_id
    3
  end

  def approve_id
    4
  end

  def reject_id
    5
  end

  def unapprove_id
    6
  end

  def take_control_id
    7
  end

  def comment_id
    8
  end

end
