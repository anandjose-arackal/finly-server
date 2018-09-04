class BankTransfer::VendorTypes::Base < BaseOperation
  def vendor_type_parameters
    params.require(:vendor_type).permit(:id, :name, :description)
  end
end