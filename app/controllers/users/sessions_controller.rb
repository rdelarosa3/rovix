# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
 def new
    super
   end

  # POST /resource/sign_in
  
  def create
   self.resource = warden.authenticate!(auth_options)
   set_flash_message(:notice, :signed_in) if is_navigational_format?
   sign_in(resource_name, resource)
   if !session[:return_to].blank?
     redirect_to session[:return_to]
     session[:return_to] = nil
   else
     redirect_to edit_user_registration_path
   end
 end
  

  # DELETE /resource/sign_out
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out
    yield if block_given?
    redirect_to new_user_registration_path
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end
end
