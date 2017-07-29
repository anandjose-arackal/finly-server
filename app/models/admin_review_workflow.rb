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

  def self.id_for(name)
    find_by(name: name)&.id
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
      # Destroy and recreate all levels
      workflow.levels.destroy_all
      config.each do |pos, users|
        users = [users] unless users.is_a?(Array)
        users.each do |user_config|
          user = user_config[:user]
          trigger_email = !!user_config[:trigger_email]
          reviewer = !!user_config[:reviewer]

          admin_user = AdminUser.with_email(user)&.first
          if admin_user.blank?
            raise "AdminUser with Email ID #{user} not found"
            return
          end
          workflow.levels.create position: pos.to_s.to_i, admin_user: admin_user, trigger_email: trigger_email, reviewer: reviewer
        end
      end
    end
  end

  def self.values
    if Rails.env.production?
      {
          # assign_card: {
          #     '0': [
          #         {user: 'vivek.a@finly.io', trigger_email: true, reviewer: true},
          #         {user: 'veekshith.rai@finly.io', trigger_email: true, reviewer: true},
          #         {user: 'anushrut.khare@finly.io', trigger_email: true, reviewer: true}
          #     ],
          #     '1': {user: 'kalpeshg.itz@intrexindia.net', trigger_email: true, reviewer: true}
          # },
          assign_card: {
              '0': [
                  {user: 'vivek.a@finly.io', trigger_email: true, reviewer: true},
                  {user: 'veekshith.rai@finly.io', trigger_email: true, reviewer: true},
                  {user: 'anushrut.khare@finly.io', trigger_email: true, reviewer: true}
              ],
              '1': [
                  {user: 'itzfinlycust@itzcash.com', trigger_email: true, reviewer: false},
                  {user: 'amitsh.itz@intrexindia.net', trigger_email: false, reviewer: true},
                  {user: 'anandy.itz@intrexindia.net', trigger_email: false, reviewer: true}
              ],
              '2': [
                  {user: 'corppayment@itzcash.com', trigger_email: true, reviewer: false},
                  {user: 'tusharm.itz@intrexindia.net', trigger_email: true, reviewer: true},
                  {user: 'kalpeshg.itz@intrexindia.net', trigger_email: true, reviewer: false},
                  {user: 'jimmyb@itzcash.com', trigger_email: false, reviewer: false},
                  {user: 'mahesht@itzcash.com', trigger_email: false, reviewer: false},
                  {user: 'pramody@itzcash.com', trigger_email: false, reviewer: false},
                  {user: 'sandeshd@itzcash.com', trigger_email: false, reviewer: false},
                  {user: 'snehalc@itzcash.com', trigger_email: false, reviewer: false},
                  {user: 'mangeshm@itzcash.com', trigger_email: false, reviewer: false}
              ]
          },
          kyc_update: {
              '0': [
                  {user: 'vivek.a@finly.io', trigger_email: true, reviewer: true},
                  {user: 'veekshith.rai@finly.io', trigger_email: true, reviewer: true},
                  {user: 'anushrut.khare@finly.io', trigger_email: true, reviewer: true}
              ],
              '1': [
                  {user: 'itzfinlycust@itzcash.com', trigger_email: true, reviewer: false},
                  {user: 'amitsh.itz@intrexindia.net', trigger_email: false, reviewer: true},
                  {user: 'anandy.itz@intrexindia.net', trigger_email: false, reviewer: true}
              ],
              '2': [
                  {user: 'corppayment@itzcash.com', trigger_email: true, reviewer: false},
                  {user: 'tusharm.itz@intrexindia.net', trigger_email: true, reviewer: false},
                  {user: 'kalpeshg.itz@intrexindia.net', trigger_email: true, reviewer: false},
                  {user: 'jimmyb@itzcash.com', trigger_email: false, reviewer: false},
                  {user: 'mahesht@itzcash.com', trigger_email: false, reviewer: false},
                  {user: 'pramody@itzcash.com', trigger_email: false, reviewer: false},
                  {user: 'sandeshd@itzcash.com', trigger_email: false, reviewer: false},
                  {user: 'snehalc@itzcash.com', trigger_email: false, reviewer: false},
                  {user: 'mangeshm@itzcash.com', trigger_email: false, reviewer: false}
              ]
          }
      }
    else
      {
          assign_card: {
              '0': [
                  {user: 'admin@demo.io', trigger_email: false, reviewer: true},
                  {user: 'sreeram@demo.io', trigger_email: true, reviewer: true}
              ],
              '1': {user: 'vivek@demo.io', trigger_email: true, reviewer: true},
              '2': [
                  {user: 'abinash@demo.io', trigger_email: false, reviewer: true},
                  {user: 'veekshith@demo.io', trigger_email: true, reviewer: false}
              ]
          },
          kyc_update: {
              '0': [
                  {user: 'admin@demo.io', trigger_email: false, reviewer: true},
                  {user: 'abinash@demo.io', trigger_email: true, reviewer: true}
              ],
              '1': {user: 'vivek@demo.io', trigger_email: true, reviewer: true},
              '2': [
                  {user: 'abinash@demo.io', trigger_email: false, reviewer: true},
                  {user: 'sreeram@demo.io', trigger_email: true, reviewer: false}
              ]
          }
      }
    end
  end

end
