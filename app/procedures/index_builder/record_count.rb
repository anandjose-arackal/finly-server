class IndexBuilder::RecordCount < IndexBuilder::StatusCount

  # COUNT return number of records in collection
  # record_count lambda can return custom logic for builder
  # in the absence of custom lambda logic, aggregate method count will call against collection
  def count(context, builder:, **)
    unless builder.try(:record_count)
     context['counter'] = context['model.records'].non_deleted.count
    else
      context['counter'] = builder.instance_exec context['model.records'], &builder.record_count
    end
    true
  end

end