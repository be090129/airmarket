MangoPay.configure do |c|
  c.preproduction =  false
  c.client_id = Rails.application.config.mangopay_clientid
  c.client_passphrase = Rails.application.config.mangopay_passphrase
end
