# this class encrypts the request before sending it to the
# ICICI bank's servers. Since all requests have the same encryption
# scheme, we can use the same class for all of them
class IciciBankApi::RequestEncrypter < IciciBankApi::Base


end