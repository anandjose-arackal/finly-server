class Tally::Generator < NonPersistentModel

  attr_accessor :company_name

  validates_presence_of :company_name
  validate :voucher_validity

  def vouchers
    @vouchers ||= []
  end

  def add_voucher(options={})
    voucher = Tally::Voucher.new(options)
    vouchers << voucher
    voucher
  end

  def as_json(options={})
    {
        "header": {
            "tallyrequest": "Import Data"
        },
        "body": {
            "importdata": {
                "requestdesc": {
                    "reportname": "Vouchers",
                    "staticvariables": {
                        "svcurrentcompany": self.company_name
                    }
                },
                "requestdata": {
                    "tallymessage": {
                        "": vouchers.as_json
                    },
                    attributes!: {
                        tallymessage: {
                            "xmlns:UDF":"TallyUDF"
                        }
                    }
                }
            }
        }
    }
  end

  def as_xml(options={})
    Gyoku.xml(as_json, key_converter: lambda { |key| key.upcase }).gsub("<>","").gsub("</>", "")
  end

  protected

  def voucher_validity
    vouchers.each do |voucher|
      unless voucher.valid?
        errors.add :base, voucher.errors.full_messages.join(', ')
      end
    end
  end

end