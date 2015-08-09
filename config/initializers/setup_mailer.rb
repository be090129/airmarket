ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
    :address              => "smtp.mandrillapp.com",
    :port                 => 587,
    :domain               => "exclusive-villas.com",
    :user_name            => "romain@exclusive-caraibes.com",
    :password             => "GaShtTT2pBM6pykBMB6PUA",
    :authentication       => "plain",
    :enable_starttls_auto => true
}