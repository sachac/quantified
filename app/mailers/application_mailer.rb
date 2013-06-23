class ApplicationMailer < ActionMailer::Base
  ADMIN_ADDRESS = 'sacha@quantifiedawesome.com'
  default :from => ApplicationMailer::ADMIN_ADDRESS
  def feedback(info)
    @info = info
    mail(:to => ApplicationMailer::ADMIN_ADDRESS,
         :from => info[:email],
         :subject => 'Quantified Awesome: Feedback')
  end

  def welcome(user)
    mail(:to => user.email,
         :subject => 'Quantified Awesome: Welcome! Please activate your account')
  end
end
