class FormDependencyType < ApplicationRecord
  include Seedable

  def self.values
    [:user, :field]
  end

end
