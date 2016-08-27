require 'active_support/concern'

module PolicyVersion
  extend ActiveSupport::Concern
  # Used to mark parent policy record as updated when an attribute in associated models is updated.
  # Without this, policy version would update only when its attributes is updated

  included do
    before_save :update_parent_version
    # before_save :check_change
    has_paper_trail
  end

  # def check_change
  #   if Proc.new { self.changed_notably? or self.marked_for_destruction? }
  #     self.policy.touch_with_version
  #   end
  # end


  def update_parent_version
    return if self.policy.blank? or self.policy.id.blank? or not self.policy.is_a?(Policy) or self.versions.count == 0
    return unless changed_notably? or marked_for_destruction?
    # self.policy.update_attribute(:updated_at, DateTime.now)
    self.policy.touch_with_version
  end

end