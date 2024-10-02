class HomeController < ApplicationController
  skip_authorization_check :only => [:feedback, :send_feedback, :privacy]
  def index
    authorize! :view_dashboard, current_account
    flash.keep
    if current_account then
      @dates = 7.downto(0).collect { |i| Time.zone.now.to_date - i.days }
      @contexts = current_account.contexts.select('id, name')
      @current_activity = current_account.records.activities.order('timestamp DESC').first
      @goal_summary = Goal.check_goals(current_account)
    end
    if mobile?
      render 'mobile_index'
    end
  end

  def menu
    authorize! :view_dashboard, current_account
  end

  def feedback
    authorize! :send_feedback, User
    @email = current_user ? current_user.email : ''
  end

  def send_feedback
    authorize! :send_feedback, User
    if !params[:message].blank?
      ApplicationMailer.feedback(params).deliver
      add_flash notice: "Your feedback has been sent. Thank you!"
      go_to root_path
    else
      add_flash :error, "Please fill in your feedback message."
      @email = params[:email].blank? ? (current_user ? current_user.email : '') : params[:email]
      render 'feedback'
    end
  end

  def privacy
    render 'terms_privacy'
  end
end
