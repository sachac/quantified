class HomeController < ApplicationController
  skip_authorization_check :only => [:feedback, :send_feedback, :privacy]
  def index
    authorize! :view_dashboard, current_account
    flash.keep
    @clothing_today = ClothingLog.where('date = ?', Time.zone.now.to_date)
    if current_account then
      @clothing_logs = current_account.clothing_logs.select('clothing_logs.date, clothing.clothing_logs_count, clothing.last_worn, clothing.image_file_name').includes(:clothing).references(:clothing).where('date >= ? and date <= ?', Time.zone.now.to_date - 1.week, Date.today).order('date, outfit_id DESC, clothing.clothing_type')
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
