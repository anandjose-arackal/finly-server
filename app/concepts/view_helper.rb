class ViewHelper

  MAP = {
      personal: [:personal, nil],
      admin: :admin,
      team: [:manager, :finance_manager, :travel_manager]
  }.each do |view, *values|
    define_singleton_method "#{view}?" do |params|
      values.include?(params&.dig(:view))
    end
  end

end