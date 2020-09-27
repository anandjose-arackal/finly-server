class PolicyIndex < SearchIndex::Model
  index Indexes::VpRecords do
    serialize do |record|
      {
          policy_id: [record.id],
          policy_name: [record.name],
      }
    end
  end
end