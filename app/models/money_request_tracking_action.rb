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

  ACTIONS={create: 1, retract: 2, submit: 3, approve: 4, reject: 5, unapprove: 6, take_control: 7, credited: 8}

  self.class.instance_eval do
    ACTIONS.each do |key, value|
      define_method "#{key}_id" do
        value
      end
    end
  end

end
