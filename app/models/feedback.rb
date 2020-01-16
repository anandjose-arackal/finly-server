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

class Feedback < ApplicationRecord
  belongs_to :feedback_type, optional: true
  belongs_to :user, optional: true
end
