MangoPay.configure do |c|
  c.preproduction = Rails.application.config.mangopay_sandbox
  c.client_id = Rails.application.config.mangopay_clientid
  c.client_passphrase = Rails.application.config.mangopay_passphrase
end
