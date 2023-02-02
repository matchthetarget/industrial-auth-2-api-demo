class UsersController < ApplicationController
  before_action :set_user, only: %i[ show liked feed discover ]

  before_action :must_be_owner_to_view, only: %i[ feed discover ]

  private

    def set_user
      if json_request?
        @user = tokenized_user
      elsif params[:username]
        @user = User.find_by!(username: params.fetch(:username))
      else
        @user = current_user
      end
    end

    def must_be_owner_to_view
      if json_request? && @user.blank?
        render json: { status: 401, message: "You're not authorized for that." }
      elsif current_user != @user
        redirect_back fallback_location: root_url, alert: "You're not authorized for that."
      end
    end
end
