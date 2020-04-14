class IndexBuilder::ContentTypes::ProgressBar < IndexBuilder::ContentTypes::Base

  register :progress_bar

  attribute :value
  attribute :tool_tip, default: -> (context) { context[:attribute].value}

end