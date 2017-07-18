# == Schema Information
#
# Table name: admin_review_workflows
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AdminReviewWorkflow < ActiveRecord::Base
  include Seedable

  has_many :levels, class_name: 'AdminReviewWorkflowLevel', dependent: :destroy

  def self.values
    {
        assign_card: {
            '0': ['admin@demo.io', 'sreeram@demo.io'],
            '1': 'vivek@demo.io',
            '2': 'veekshith@demo.io'
        },
        kyc_update: {
            '0': ['admin@demo.io', 'sreeram@demo.io'],
            '1': 'veekshith@demo.io'
        }
    }
  end

  def self.id_for(name)

  end

  def self.workflow_for(name)
    find_by(name: name)
  end

  def self.seed_data
    AdminReviewWorkflow.values.each do |name, config|
      workflow = AdminReviewWorkflow.workflow_for(name)
      if workflow.blank?
        # create new workflow
        workflow = AdminReviewWorkflow.create name: name
      end
      workflow.levels.destroy_all
      config.each do |pos, emails|
        emails = [emails] unless emails.is_a?(Array)
        emails.each do |email|
          reviewer = AdminUser.with_email(email)&.first
          if reviewer.blank?
            raise "AdminUser with Email ID #{email} not found"
            return
          end
          workflow.levels.create position: pos.to_s.to_i, admin_reviewer: reviewer
        end
      end
    end
  end

end
