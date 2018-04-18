# == Schema Information
#
# Table name: travel_request_comment_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TravelRequestCommentAction < ActiveRecord::Base
end
