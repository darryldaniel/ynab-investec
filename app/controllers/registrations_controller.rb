class RegistrationsController < ApplicationController
    http_basic_authenticate_with name: ENV.fetch("APP_USERNAME"), password: ENV.fetch("APP_PASSWORD")

    def new
       @user = User.new
    end

    def create
        @user = User.new(registration_params)
        if @user.save
            login @user
            redirect_to root_path
        else
            render :new, status: :unprocessable_entity
        end
    end

    private

    def registration_params
        params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
