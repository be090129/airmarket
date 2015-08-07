#
# This class makes Mangopay calls thread-safe even though we're using
# different configurations per Mangopay call
#
class MangopayApi
  class << self

    @@mutex = Mutex.new

    # This method should be used for all actions that require setting correct
    # Merchant details for the Mangopay gem
    def with_mangopay_config(&block)
      @@mutex.synchronize {
        #configure_for(community)
        begin
          return_value = block.call
        rescue MangoPay::ResponseError => mangopay_error
          Rails.logger.error(mangopay_error.message)
          return_value = mangopay_error
        end
        #reset_configurations()
        puts "APPPEL MANGOPAY"
        puts return_value
        #puts JSON.pretty_generate(return_value).gsub(" "," ")
        return return_value
      }
    end

    def create_user_id(contact)
      with_mangopay_config() do
        MangoPay::NaturalUser.create({
                                         :FirstName => contact.first_name,
                                         :LastName => contact.last_name,
                                         :Email => contact.email,
                                         :Address => {
                                             :AddressLine1 => contact.adressline1,
                                             :AddressLine2=> "",
                                             :City=> contact.city,
                                             :Region=> contact.region,
                                             :PostalCode=> contact.postalcode,
                                             :Country=> contact.country,
                                         },
                                         :Nationality => contact.nationality,
                                         :Birthday => contact.birthday.to_time.to_i,
                                         :CountryOfResidence => contact.country,
                                         :Tag=> "User"
                                     })
      end
    end

    def update_user_id(contact)
      with_mangopay_config() do
        MangoPay::NaturalUser.update(contact.mangopay_user_id,{
          :FirstName => contact.first_name,
          :LastName => contact.last_name,
          :Email => contact.email,
          :Address => {
            :AddressLine1 => contact.adressline1,
            :AddressLine2=> "",
            :City=> contact.city,
            :Region=> contact.region,
            :PostalCode=> contact.postalcode,
            :Country=> contact.country,
            },
          :Nationality => contact.nationality,
          :Birthday => contact.birthday.to_time.to_i,
          :CountryOfResidence => contact.country,
          :Tag=> "User"
        })
      end
    end

    def create_user_wallet(contact, owner_id)
      with_mangopay_config() do
        MangoPay::Wallet.create({
                                    :Owners => [owner_id],
                                    :Description => contact.first_name+"/"+contact.last_name+ " wallet",
                                    :Tag => contact.first_name+"/"+contact.last_name+ " wallet",
                                    :Currency => "EUR"
                                })
      end
    end

    def update_user_wallet(contact)
      with_mangopay_config() do
        MangoPay::Wallet.update(contact.mangopay_wallet_id,{
                                                              :Description => "Wallet exclusive user",
                                                              :Tag => "Updated wallet"
                                                          })
      end
    end

    def transfer_between_wallets(debited_wallet_id, credited_wallet_id,debited_user_id, credited_user_id,transfer_amount,fees_amount)
      with_mangopay_config() do
        MangoPay::Transfer.create({
                                      :AuthorId=>debited_user_id,
                                      :CreditedUserId=>credited_user_id,
                                      :DebitedWalletID=>debited_wallet_id,
                                      :CreditedWalletID=>credited_wallet_id,
                                      :DebitedFunds=>{:Currency=>"EUR",:Amount=>transfer_amount},
                                      :Fees=>{:Currency=>"EUR",:Amount=>fees_amount},
                                      :Tag=>"Location OK, versement des fonds sur la wallet du proprio"
                                  })
      end
    end

    def payout(debited_wallet_id,debited_user_id,bank_user_id,transfer_amount,fees_amount,tag)
      with_mangopay_config() do
        MangoPay::PayOut::BankWire.create({
                                              :AuthorId=>debited_user_id,
                                              :DebitedWalletId=>debited_wallet_id,
                                              :DebitedFunds=>{:Currency=>"EUR",:Amount=>transfer_amount},
                                              :Fees=>{:Currency=>"EUR",:Amount=>fees_amount},
                                              :BankAccountId=>bank_user_id,
                                              :Tag=>tag
                                          })
      end
    end

    def create_user_bank(contact, owner_id)
      with_mangopay_config() do
        MangoPay::BankAccount.create(owner_id,{
                                                 :Type => "IBAN",
                                                 :OwnerName => contact.first_name + " "+ contact.last_name,
                                                 :OwnerAddress => {
                                                     :AddressLine1 => contact.adressline1,
                                                     :AddressLine2=> "",
                                                     :City=> contact.city,
                                                     :Region=> contact.region,
                                                     :PostalCode=> contact.postalcode,
                                                     :Country=> contact.country,
                                                 },
                                                 :UserId => owner_id,
                                                 :IBAN => contact.iban,
                                                 :BIC => contact.bic
                                             }
        )
      end
    end

    def create_cb_registration(owner_id)
      with_mangopay_config() do
        MangoPay::CardRegistration.create({
                                              :UserId=>owner_id,
                                              :Currency=>"EUR"
                                          })
      end
    end

    def update_cb_registration(pre_card_register)
      with_mangopay_config() do
        MangoPay::CardRegistration.update(pre_card_register["Id"],{
                                                                     :RegistrationData=>pre_card_register["RegistrationData"]
                                                                 })
      end
    end

    def fetch_cb_registration(pre_card_register)
      with_mangopay_config() do
        MangoPay::CardRegistration.fetch(pre_card_register["Id"])
      end
    end

    def fetch_card_alias(card_id)
      with_mangopay_config() do
        MangoPay::Card.fetch(card_id)
      end
    end

    def create_payin(mangopay_account,debit_amount_cents,currency,fees_amount_cents,secureModeReturnURL)
      with_mangopay_config() do
        MangoPay::PayIn::Card::Direct.create({
                                                 :AuthorId=>mangopay_account.mangopay_user_id,
                                                 :DebitedFunds=>{:Currency=>currency,:Amount=>debit_amount_cents},
                                                 :Fees=>{:Currency=>currency,:Amount=>fees_amount_cents},
                                                 :CreditedWalletId=>mangopay_account.mangopay_wallet_id,
                                                 :CardId=>mangopay_account.mangopay_card_id,
                                                 :SecureMode=>"DEFAULT",
                                                 :SecureModeReturnURL=>secureModeReturnURL
                                             })
      end
    end

    def fetch_payin(payin_id)
      with_mangopay_config() do
        MangoPay::PayIn.fetch(payin_id)
      end
    end

    def refund_payin(payin_id,authorId)
      with_mangopay_config() do
        MangoPay::PayIn.refund(payin_id,{:AuthorID=>authorId})
      end
    end


    def isInError(result_api_call)
      return (result_api_call.instance_of? MangoPay::ResponseError) || ((!result_api_call.instance_of? MangoPay::ResponseError) && (result_api_call["Status"]!="SUCCEEDED" && result_api_call["Status"]!="CREATED"))
    end

    def isIn3dSecure(result_api_call)
      return (result_api_call["Status"]=="CREATED" && result_api_call["SecureModeNeeded"]==true)
    end

    def process_error(error_action,error_alert,error_info,error_solution,error_details)
      error_action="" if error_action.nil?
      error_alert="" if error_alert.nil?
      error_info="" if error_info.nil?
      error_solution="" if error_solution.nil?
      error_details="" if error_details.nil?
      #Log + mail for admin
      #MangopayLog.error(error_action + " / " +error_alert+ " / "+error_info+" / "+error_solution+ " / "+error_details.to_param)
      # Flash error for user
      error_alert="- <u>Erreur:</u> "+ error_alert if error_alert
      error_info="- <u>Erreur info:</u> "+ error_info if error_info
      error_solution="- <u>Erreur solution:</u> "+ error_solution if error_solution

      errors = [error_alert,error_info,error_solution]
      errors.join("<br/>").html_safe
    end

  end
end
