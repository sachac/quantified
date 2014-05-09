class ApplicationMailer < ActionMailer::Base
  ADMIN_ADDRESS = 'sacha@quantifiedawesome.com'
  default :from => ApplicationMailer::ADMIN_ADDRESS
  def feedback(info)
    @info = info
    mail(:to => ApplicationMailer::ADMIN_ADDRESS,
         :from => 'sacha@quantifiedawesome.com',
         :subject => 'Quantified Awesome: Feedback')
  end

end
