class IciciStatementsFetch < ActiveJob::Base

  def perform
    Company.all.each do |company|
      unless company.bank_service_provider == "ICICI"
        next
      end
      op = IciciBankApi::AccountStatement.(company, {start_date: Date.yesterday, end_date: Date.today})
      unless op.success?
        # trigger email notifying the fact that the statement fetch failed
        # todo
      end
    end
  end
end