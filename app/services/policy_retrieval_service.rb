class PolicyRetrievalService < BaseService
  attr_accessor :user

  def initialize(user)
    super()
    self.user= user
  end

  def self.for_report(report)
    return report.user.company.default_policy.first rescue nil unless report.policy.present?
    if report.submitted_at.present?
      return report.policy.version_at report.submitted_at, has_many: true, has_one: true, belongs_to: true
    end
    report.policy
  end

  def list(params={})
    if user.blank?
      errors << 'No user selected'
      return false
    end
    load_view params
    if @admin_view and user.admin? # Admin can view all policies
      user.company.policies.non_default if user.company.policies
    elsif @admin_view and user.policy_admin?
      # i.e. all policies this user is an admin for
      user.admin_policies if user.admin_policies
    elsif @personal_view # User would get a list of policies he is added to
      user.policies.non_default if user.policies
    end
  end

end