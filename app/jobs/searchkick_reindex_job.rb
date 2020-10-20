class SearchkickReindexJob
  def self.perform(reindex: false)
    Searchkick.models.each do |model|
      if reindex
        model.reindex
      else
        Searchkick::ProcessQueueJob.new.perform(class_name: model.name, inline: true)
      end
    end

    true
  end
end