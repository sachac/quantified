class HomeController < ApplicationController
  skip_authorization_check :only => [:sign_up, :feedback, :send_feedback]
  def index
    authorize! :view_dashboard, current_account
    flash.keep
    @clothing_today = ClothingLog.where('date = ?', Time.zone.now.to_date)
    if current_account then
      @clothing_logs = current_account.clothing_logs.select('clothing_logs.date, clothing.clothing_logs_count, clothing.last_worn, clothing.image_file_name').includes(:clothing).where('date >= ? and date <= ?', Time.zone.now.to_date - 1.week, Date.today).order('date, outfit_id DESC, clothing.clothing_type')
      @clothing_tags = current_account.clothing.tag_counts_on(:tags).sort_by(&:name)
      @by_date = current_account.clothing_logs.by_date(@clothing_logs)
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

  def sign_up
    if !params[:email].blank?
      @new_user = Signup.create(:email => params[:email])
      if @new_user.save!
        logger.info "NEW USER #{@new_user.inspect}"
        flash[:notice] = "Thank you for your interest!"
        redirect_to root_path and return
      else
        flash[:error] = "Could not save information. Sorry! Could you please get in touch with me at sacha@sachachua.com instead?"
      end
    end
    redirect_to new_user_session_path and return
  end

  def feedback
    authorize! :send_feedback, User
  end

  def send_feedback
    authorize! :send_feedback, User
    info = params
    if !params[:message].blank?
      if current_account && current_account.id != 1
        info[:user_id] = current_account.id
        info[:email] = current_account.email
      end
      ApplicationMailer.feedback(info).deliver
      add_flash notice: "Your feedback has been sent. Thank you!"
      go_to root_path
    else
      add_flash :error, "Please fill in your feedback message."
      render 'feedback'
    end
  end
end
