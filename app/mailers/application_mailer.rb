class ApplicationMailer < ActionMailer::Base
  default :from => 'sacha@quantifiedawesome.com'
  def feedback(info)
    @info = info
    mail(:to => 'sacha@quantifiedawesome.com',
         :subject => 'Quantified Awesome: Feedback')
  end
end
