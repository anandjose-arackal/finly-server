class ReportSyncType < ActiveRecord::Base
  include Seedable

  def values
    [:quickbooks, :tally_export]
  end

  def as_json(options={})
    {
        id: id,
        name: name
    }
  end

end
