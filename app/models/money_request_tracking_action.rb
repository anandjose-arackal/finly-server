# == Schema Information
#
# Table name: money_request_tracking_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MoneyRequestTrackingAction < ActiveRecord::Base

  ACTIONS={create: 1, retract: 2, submit: 3, approve: 4, auto_approve: 5, reject: 6, unapprove: 7, take_control: 8, credited: 9}

  self.class.instance_eval do
    ACTIONS.each do |key, value|
      define_method "#{key}_id" do
        value
      end
    end
  end

  def self.id_for(action)
    ACTIONS[action]
  end

end
