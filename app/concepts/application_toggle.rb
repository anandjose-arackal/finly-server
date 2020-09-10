# ApplicationToggle is used for facilitating dynamism depending on the customer / user into the application.
#
# === Use-cases
# * CSI / Sales Team / Billing team would benefit from being able to configure limits on the application depending on the billing package the customer is under
#   * Sales team can easily create packages for customers
#   * Billing team can enforce limitations such as users count and invoices count to ensure customers do not exceed these predefined limitations
# * Development / Product team can design paths for AB testing and provide values for the necessary routing
#
# === Dependency
# ApplicationToggle primarily relies on FeatureToggle (defined in https://control-panel.finly.io) for fetching dynamic configurations.
# Every control point or attribute would be available as a separate method having its own pre-defined values.
class ApplicationToggle
  attr_reader :user, :record

  def initialize(user, record=nil)
    @user = user
    @record = record
  end

  def feature_value(feature, default = nil)
    user.feature_toggle.value(feature, default)
  end

end