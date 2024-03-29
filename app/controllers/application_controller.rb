class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?

  def admin
    authenticate_or_request_with_http_basic do |username, password|
      username == USER_ID && password == USER_PASSWORD
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:last_name, :first_name, :adressline1, :city, :region, :postalcode, :country, :nationality, :birthday, :email, :password) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:last_name, :first_name, :adressline1, :city, :region, :postalcode, :country, :nationality, :birthday, :email, :password,:current_password, :iban, :bic, :images_attributes => [:id, :_destroy, :photo, :user_id]) }
  end

end
