class IndexBuilder::RecordCount < IndexBuilder::StatusCount

  def count(context, builder:, **)
    context['counter'] = context['model.records'].count

    true
  end

end