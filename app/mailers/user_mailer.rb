class UserMailer < ApplicationMailer
  default from: 'admin@example.com'

  def registration_completed(user)
    @user = user
    # app/mailers/user_mailer.rb
    mail(to: @user.email, subject: '登録完了')
  end
end