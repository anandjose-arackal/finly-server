class PolicyRetrievalService < BaseService
  attr_accessor :user

  def initialize(user)
    super()
    self.user= user
  end

  def self.for_report(report)
    return report.user.company.default_policy unless report.policy.present?
    report.policy
  end

  def list(params={})
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