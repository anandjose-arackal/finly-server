
# {"policy_user_role"=>{"user_ids"=>["15"], "view"=>"admin", "user_role_id"=>"16"}, "policy_id"=>"4"}

class PolicyUserRoles::BulkAssign < PolicyUserRoles::Base
  attr_accessor :policy_user_roles, :user_roles

  def init
    bulk_assign = params[:bulk_assign]
    self.policy_ids = bulk_assign[:policy_ids]
    self.user_role_ids = bulk_assign[:user_role_ids]
    self.user_ids = bulk_assign[:user_ids]
  end

  def validate

  end

  def process
    self.policy_ids.each do |policy|
      self.user_role_ids do |user_role|
        params[:policy_user_role] = {user_ids: self.user_ids, user_role_id: user_role}
        params[:policy_id] = policy

        PolicyUserRoles::Create.(current_user, params)
        
      end
    end
  end

  def success
    PolicyUserRoles::BulkAssign::IndexPresenter.new(user, params, messages)
  end

  class PolicyUserRoles::BulkAssign::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter

    def init

    end
  end
end