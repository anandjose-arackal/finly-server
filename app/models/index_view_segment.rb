# == Schema Information
#
# Table name: index_view_segments
#
#  id             :bigint           not null
#  uuid           :string(36)       not null, primary key
#  screen         :string(255)      not null
#  name           :string(255)      not null
#  filters        :text(65535)
#  columns        :text(65535)
#  system_view    :boolean          default(FALSE)
#  company_id     :integer
#  user_id        :integer
#  last_viewed_at :datetime
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class IndexViewSegment < ApplicationRecord
  include UUIDHelper, ::Filters::Store

  belongs_to :user
  belongs_to :company

  filter_store :filters
  # serialize :filters, JSON
  serialize :columns, JSON

  event_channel :index_view_segments

  default_scope { order(name: :asc) }

  def as_json(options = {})
    {
        id: id,
        name: name,
        filters: filters,
        default: default,
        columns: columns
    }
  end
end
