class ApplicationMailer < ActionMailer::Base
  default :from => 'sacha@quantifiedawesome.com'
  def feedback(info)
    @info = info
    mail(:to => 'sacha@quantifiedawesome.com',
         :from => info[:email],
         :subject => 'Quantified Awesome: Feedback')
  end

  def welcome(user)
    mail(:to => user.email,
         :subject => 'Quantified Awesome: Welcome! Please activate your account')
  end
end
