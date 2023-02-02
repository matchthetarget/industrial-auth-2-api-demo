class ApplicationController < ActionController::Base
  acts_as_token_authentication_handler_for User,
    if: ->(controller) { controller.user_token_authenticable? }

  respond_to :html, :json
  protect_from_forgery with: :null_session, if: :json_request?
  before_action :authenticate_user!, unless: :json_request?

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def user_token_authenticable?
    # This ensure the token can be used only for JSON requests (you may want to enable it for XML too, for example)
    return false unless request.format.json?
    return false if tokenized_user_identifier.blank?

    # `nil` is still a falsy value, but I want a strictly boolean field here
    tokenized_user.try(:token_authenticable?) || false
  end

  def json_request?
    request.format.json?
  end
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :private, :name, :bio, :website, :avatar_image])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :private, :name, :bio, :website, :avatar_image])
  end


  private

  def tokenized_user
    # I use email with devise, you can use whatever you want
    User.find_by(email: tokenized_user_identifier.to_s)
  end

  def tokenized_user_identifier
    # Customize this based on Simple Token Authentication settings
    request.headers['X-User-Email'] || params[:user_email]
  end
end
