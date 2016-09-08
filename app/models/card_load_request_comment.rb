# == Schema Information
#
# Table name: card_load_request_comments
#
#  id                   :integer          not null, primary key
#  card_load_request_id :integer          not null
#  comment_action_id    :integer          not null
#  user_id              :integer
#  expense_id           :integer
#  updated_field        :string(255)
#  updated_from         :text(65535)
#  updated_to           :text(65535)
#  rejected_to_id       :integer
#  content              :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class CardLoadRequestComment < ActiveRecord::Base

  belongs_to :card_load_request
  belongs_to :comment_action, class_name: 'CardLoadRequestCommentAction'
  belongs_to :user
  belongs_to :expense
  belongs_to :rejected_to, class_name: 'User'

end
