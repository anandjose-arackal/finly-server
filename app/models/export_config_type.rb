class ExportConfigType < ActiveRecord::Base
  include Seedable

  def self.values
    [
        :procurement
    ]
  end

end
