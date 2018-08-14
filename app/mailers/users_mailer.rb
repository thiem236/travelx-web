class UsersMailer < ApplicationMailer

  def send_verification_code(user)
    @user = user
    mail to: @user.email, subject: " TravelX - Verification code for your account"
  end

  def send_pass_reset_code(user)
    @user = user
    mail to: @user.email, subject: " TravelX - Reset password code"
  end
end