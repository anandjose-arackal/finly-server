class Integrations::Quickbooks::SyncCompanyTags < Integrations::Base

  def process
    company_tags = adapter.tags
    # for now these are being stored in the local db as Finly Company tags, so we have to figure out the use cases later
    company_tags.each do |tag|
      tag.save
    end
  end

  def post_process

  end


end