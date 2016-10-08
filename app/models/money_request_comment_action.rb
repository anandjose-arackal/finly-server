# == Schema Information
#
# Table name: money_request_comment_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class MoneyRequestCommentAction < ActiveRecord::Base

  ACTIONS = {create: 1, retract: 2, submit: 3, approve: 4, approve_and_forward: 5, auto_approve: 6, reject: 7, unapprove: 8,
             take_control: 9, comment: 10, update: 11, credited: 12}

  self.class.instance_eval do
    ACTIONS.each do |key,value|
      define_method "#{key}_id" do
        value
      end
    end
  end

  def self.id_for(action)
    ACTIONS[action]
  end

end
