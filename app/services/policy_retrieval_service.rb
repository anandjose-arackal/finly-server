class PolicyRetrievalService < BaseService

  def self.for_report(report)

  end


  def list(user, params={})
    if user.blank?
      errors << 'No user selected'
      return false
    end
    load_view params
    if @admin_view # Admin can view all policies
      user.company.policies.non_default
    elsif @personal_view # User would get a list of policies he is added to
      user.company.policies.non_default
    end
  end

end