class IciciBankTransferRequest < NonPersistentModel

  attr_accessor :beneficiary_account_number, :ifsc, :beneficiary_name, :transfer_type,
                :transfer_currency_code, :transfer_amount, :unique_reference_number,
                :bank_reference_number, :company_id,
                :bank_error_message, :transaction_result,
                :error_code

  belongs_to :company, optional: true

  validates :company_id, presence: true
  validates :beneficiary_account_number, presence: true
  validates :beneficiary_name, presence: true
  validates :ifsc, presence: true
  validates :transfer_currency_code, presence: true
  validates :transfer_amount, presence: true
  validates :transfer_type, presence: true

  def self.call(beneficiary_name, beneficiary_account_number, ifsc, transfer_amount, transfer_type, unique_reference_number, company_id, transfer_currency = "INR")
    self.new({
                 beneficiary_account_number: beneficiary_account_number,
                 beneficiary_name: beneficiary_name,
                 ifsc: ifsc,
                 transfer_type: retrieve_transfer_type(transfer_type),
                 transfer_amount: transfer_amount,
                 transfer_currency_code: transfer_currency,
                 unique_reference_number: set_unique_reference(unique_reference_number, transfer_type),
                 company_id: company_id
             })
  end

  def self.set_unique_reference(unique_reference_number, transfer_type)
    if unique_reference_number.present?
      return unique_reference_number
    end
    ref = nil
    loop do
      # this has a limit of 13 characters because it gets truncated in the statements from ICICI
      ref = "FI#{(transfer_type.to_s)[0..1]&.upcase}#{rand.to_s[2..11]}"
      if IciciBankTransaction.find_by(unique_request_number: ref).blank?
        return ref
        break
      end
    end
    ref
  end

  def generate_unique_reference
    if self.unique_reference_number.present?
      return self.unique_reference_number
    end
    ref = nil
    loop do
      # this has a limit of 13 characters because it gets truncated in the statements from ICICI
      ref = "FI#{(transfer_type.to_s)[0..1]&.upcase}#{rand.to_s[2..11]}"
      if IciciBankTransaction.find_by(unique_request_number: ref).blank?
        self.unique_reference_number = ref
        break
      end
    end
    ref
  end

  def as_json(options={})
    {
        beneficiary_account_number: beneficiary_account_number,
        beneficiary_name: beneficiary_name,
        ifsc: ifsc,
        transfer_type: transfer_type,
        transfer_amount: transfer_amount,
        transfer_currency_code: transfer_currency_code,
        unique_reference_number: unique_reference_number,
        company_id: company_id,
        company_name: company&.name
    }
  end

  def self.retrieve_transfer_type(transfer_type)
    case transfer_type.upcase
      when "RTGS", "rtgs"
        return "RTG"
      when "NEFT", "neft"
        return "RGS"
      when "IMPS", "imps"
        return "IFS"
      else # anomalous case, return nothing
        return ""
    end
  end

end