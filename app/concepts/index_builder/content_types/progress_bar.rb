class IndexBuilder::ContentTypes::ProgressBar < IndexBuilder::ContentTypes::Base

  register :progress_bar

  attribute :value
  attribute :total_count
  attribute :completed_count
  attribute :tool_tip, default: -> (context) { context[:attribute].value}

end