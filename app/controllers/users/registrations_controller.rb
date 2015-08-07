class Users::RegistrationsController < Devise::RegistrationsController
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   createMangopayAccount(@contact)
  # end

  def createMangopayAccount(contact)
    if contact.mangopay_user_id
      return_value=MangopayApi.update_user_id(contact)
    else
      return_value=MangopayApi.create_user_id(contact)
    end
    mangopay_api_throws_an_error(return_value) ? (error=return_value) : (user_id=return_value["Id"])

    if error.nil?
      if contact.mangopay_wallet_id
        return_value=MangopayApi.update_user_wallet(contact)
      else
        return_value=MangopayApi.create_user_wallet(contact,user_id)
      end

      mangopay_api_throws_an_error(return_value) ? (error=return_value) : (wallet_id=return_value["Id"])

      if contact.iban.present? && contact.bic.present?
        return_value=MangopayApi.create_user_bank(contact,user_id)
        mangopay_api_throws_an_error(return_value) ? (return {errorbank: return_value}) : (bank_id=return_value["Id"])
      end

      if error.nil?
        contact.mangopay_user_id=user_id
        contact.mangopay_wallet_id=wallet_id
        contact.mangopay_bank_id=bank_id if bank_id
        contact.save
      end
    end
  end

  def mangopay_api_throws_an_error(returned_value)
    returned_value.instance_of? MangoPay::ResponseError
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
   def update

     self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
     prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

     resource_updated = update_resource(resource, account_update_params)
     yield resource if block_given?
     if resource_updated
       if is_flashing_format?
         flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
             :update_needs_confirmation : :updated
         set_flash_message :notice, flash_key
       end
       createMangopayAccount(resource)
       sign_in resource_name, resource, bypass: true
       respond_with resource, location: after_update_path_for(resource)
     else
       clean_up_passwords resource
       respond_with resource
     end

   end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) << :attribute
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
