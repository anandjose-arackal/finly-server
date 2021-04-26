class SearchkickProcessQueueJob < BaseJob

  # Reindex queued items
  def self.perform_job
    Searchkick.models.each do |model|
      Searchkick::ProcessQueueJob.new.perform(class_name: model.name, inline: true)
    end

    true
  end

end