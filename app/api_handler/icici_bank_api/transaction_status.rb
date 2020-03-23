class IciciBankApi::TransactionStatus < IciciBankApi::Base

  attr_accessor :icici_bank_transaction, :api_response_success,
                :transaction_status_response, :params

  class IciciBankApi::TransactionStatus::TransactionStatusPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :transaction_status_response, :response

    def init
      self.transaction_status_response = params[:transaction_status_response]
      self.response = params[:response]
    end

  end

  def initialize(bank_transaction, params = {})
    self.icici_bank_transaction = bank_transaction
    self.params = {}
  end

  def self.call(bank_transaction)
    self.new(bank_transaction).run
  end

  def init
    self.company = self.icici_bank_transaction&.company
    super()
  end

  def env_key
    'icici_bank_transaction_status'
  end

  def validate
    if self.icici_bank_transaction.blank?
      add_message :error, "No transaction passed"
      return
    end

    unless self.icici_bank_transaction.pending_for_processing? || self.icici_bank_transaction.pending_utr? || self.icici_bank_transaction.possible_failure? || self.icici_bank_transaction.suspect?
      add_message :error, "Only pending UTR and pending for processing cases can be checked for status"
      return
    end
  end

  def raw_api_params
    {
        AGGRID: self.company_details["AGGR_ID"],
        CORPID: self.company_details["CORP_ID"],
        USERID: self.company_details["USER_ID"],
        URN: self.company.icici_bank_config.urn,
        UNIQUEID: self.icici_bank_transaction.unique_request_number
    }
  end

  def post_params
    encrypt_params(
        raw_api_params
    )
  end

  def post_process
    case self.response.status
      when 404

      when 500
        self.transaction_status_response = (self.parsed_response["Response"] || self.parsed_response["RESPONSE"])
        case self.transaction_status_response&.upcase
        when "FAILURE"
          self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))
        else
          # do nothing?
        end
      when 200
        self.transaction_status_response = self.parsed_response["STATUS"]
        api_response = (self.parsed_response["RESPONSE"] || self.parsed_response["Response"])
        if api_response&.upcase == "SUCCESS"
          case self.transaction_status_response&.upcase
          when "SUCCESS"
            utr = self.parsed_response["UTRNUMBER"]
            # This is because only IMPS and RTGS transactions return the UTR in the API
            # Now all transactions give UTR in the transaction status API
            if utr.present?
              # if self.icici_bank_transaction.neft?
              #   utr = "0#{utr}1"
              # end
              self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:completed), utr: utr)
            end
          when "PENDING FOR PROCESSING"
            self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:pending_for_processing))
          when "REJECTED", "RECALLED"
            self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:rejected))
          when "SUSPECT"
            # this seems to be a temporary status which can then swing either way after a while. So adding this to the list of statuses that we shall regularly scan for statuses later
            self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:suspect))
          when "PENDING"
            self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:pending))
          when "FAILURE"
            self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))
          when "CANCELLED"
            self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:cancelled))
          else
            # do nothing?
          end
        elsif api_response&.upcase == "FAILURE"
          # this condition is because apparently, for IMPS transactions, the message being sent is: "Session could not be retrieved"
          message = self.parsed_response["MESSAGE"] || self.parsed_response["Message"]
          if self.icici_bank_transaction.imps? && message.downcase == "session could not be retrieved"
            self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))
          end
          if message == "Invalid Inquiry Req id or unique Id"
            self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))
          end
        else
          message = self.parsed_response["MESSAGE"] || self.parsed_response["Message"]
          if message == "Invalid Inquiry Req id or unique Id"
            self.icici_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))
          end
        end
      else
        # handle it gracefully
    end
  end

  def success?
    self.transaction_status_response.present?
  end

  def failure?
    self.transaction_status_response.blank?
  end

  def success
    params[:transaction_status_response] = self.transaction_status_response
    params[:response] = self.response
    IciciBankApi::TransactionStatus::TransactionStatusPresenter.new(user, params, messages)
  end

end