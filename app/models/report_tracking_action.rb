# == Schema Information
#
# Table name: report_tracking_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#




class ReportTrackingAction < ActiveRecord::Base


  VALUES = { create: 1,
             retract: 2,
             submit: 3,
             approve: 4,
             auto_approve: 5,
             reject: 6,
             unapprove: 7,
             take_control: 8,
             reimbursed: 9,
             reimbursement_confirmed: 10,
             closed: 11
            }

  self.class.instance_eval do
    VALUES.each do |key, value|
      define_method "#{key}_id" do
        value
      end
    end
  end

  def self.id_for(sym)
    VALUES[sym]
  end


end
