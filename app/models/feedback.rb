# == Schema Information
#
# Table name: feedbacks
#
#  id               :integer          not null, primary key
#  feedback_type_id :integer          not null
#  content          :text(65535)      not null
#  user_id          :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Feedback < ActiveRecord::Base
  belongs_to :feedback_type
  belongs_to :user
end
