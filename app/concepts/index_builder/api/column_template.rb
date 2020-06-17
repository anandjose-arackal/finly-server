# Standard set of columns that can be reused across most documents/records
class IndexBuilder::API::ColumnTemplate

  def self.ControllingUser(klass)
    klass.column :controlling_user, default: true, includes: [:document_level_reviewer_mappings, :level] do
      user value: -> (context) { context[:record].get_reviewers.first }
      text value: -> (context) do
        count = context[:record].get_reviewer_ids.count
        if count > 2
          "+ #{count} Reviewers"
        else
          # To avoid FE from keeping a dashed (--) placeholder
          " "
        end
      end
    end
  end

  def self.ControllingLevel(klass)
    klass.column :controlling_level, default: true, includes: [:controlling_level] do
      text value: "{{record.controlling_level.name}}"
      text value: -> (context) do
        if context[:record].review_in_progress? and context[:record].controlling_level.present?
          "Level: #{context[:record].controlling_level.level_number}"
        else
          " "
        end
      end
    end
  end

  def self.ReviewProgress(klass)
    klass.column :progress, label: 'Approval Progress', default: true, includes: [:document_level_reviewer_mappings] do
      progress_bar value: ->(context) {context[:record].review_progress || 0},
                   completed_count: ->(context) {context[:record].reviewers_completed_count || 0},
                   total_count: ->(context) {context[:record].reviewers_count || 0}
    end
  end
end