require 'openssl'
OpenSSL::Engine.load
engine = OpenSSL::Engine.by_id('gost')
engine.set_default(0xFFFF)


cert   = OpenSSL::X509::Certificate.new File.binread('config/keys/gost_keys/certificate.crt')
pkey   = OpenSSL::PKey.read(File.read('config/keys/gost_keys/private.key'))

digester  = engine.digest('md_gost12_256')

data = 'dfsdfsdfsdfsdf'

signature = pkey.sign(digester, data)
puts "Signature #{signature}"
puts "Verified? - #{cert.public_key.verify(digester, signature, data)}"
