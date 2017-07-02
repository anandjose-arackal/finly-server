require 'base64'
require 'digest'
require 'openssl'

class Aes256EncryptorDecryptor

  KEY = "a2fb675a04082d5082354200b170555298fe7326a408e72f3ae5ff807327b8a7"
  ALGORITHM = 'AES-256-CBC'
  IV = "42bb6d311df6dc6437cee2d3dd135d06"


  def self.encrypt(cleardata, password = KEY, iv = IV)
    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    cipher.encrypt  # set cipher to be encryption mode
    cipher.key = password
    cipher.iv  = iv
    cipher.padding = 1

    encrypted = ''
    encrypted << cipher.update(cleardata)
    encrypted << cipher.final
    encrypted.unpack('H*')
  end

  def self.decrypt(secretdata, password = KEY, iv = IV)
    secretdata = Base64::decode64(secretdata)
    decipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    decipher.decrypt
    decipher.key = password
    decipher.iv = iv if iv != nil
    decipher.update(secretdata) + decipher.final
  end

  def self.aes256_cbc_encrypt(data, key = KEY, iv = IV)
    aes = OpenSSL::Cipher.new('AES-256-CBC')
    aes.encrypt
    aes.key = key
    aes.iv = iv
    aes.padding = 1
    enc = aes.update(data) + aes.final
  end

  private

  def self.b64enc(data)
    Base64.encode64(data).gsub(/\n/, '')
  end

end