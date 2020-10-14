class IndexBuilder::RecordCount < IndexBuilder::StatusCount

  def count(context, builder:, **)
    context['counter'] = context['model.records'].non_deleted.count

    true
  end

end