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
  def summary
    @start = (!params[:start].blank? ? Time.parse(params[:start]) : Date.new(Date.today.year, Date.today.month, 1)).midnight
    @end = (!params[:end].blank? ? Time.parse(params[:end]) : Date.new(Date.today.year, Date.today.month + 1, 1)).midnight
    @log = TimeTrackerLog.new
    @entries = @log.entries(@start, @end)
    @time_by_day = @log.by_day(@entries)
    day = @start
    @time_graphs = Hash.new
    @cat = (@time_by_day.map { |x,y| y.keys }).flatten.uniq
    @cat.each do |t| @time_graphs[t] = Array.new end
    @by_day = Hash.new
    @count_days = Hash.new
    ['Work', 'Sleep', 'Discretionary', 'Unpaid work', 'Personal care'].each do |x|
      @by_day[x] ||= Hash.new
    end
    while day < @end
      @count_days[day.wday] ||= 0
      @count_days[day.wday] += 1
      @cat.each do |t| 
        if @time_by_day[day.strftime('%Y-%m-%d')] then
          cat = nil
          time = (@time_by_day[day.strftime('%Y-%m-%d')][t] || 0) / 3600
          @time_graphs[t] << time
          if t.match /^A - Work/ 
            cat = 'Work'
          elsif t.match /^A - Sleep/ 
            cat = 'Sleep'
          elsif t.match /^D - / 
            cat = 'Discretionary'
          elsif t.match /^UW - / 
            cat = 'Unpaid work'
          elsif t.match /^P - / 
            cat = 'Personal care'
          end
          if cat
            @by_day[cat][day.wday] ||= 0
            @by_day[cat][day.wday] += time
          end
        else
          @time_graphs[t] << 0
        end
      end
      day += 1.day
    end
    
    # Summarize weekends and weekdays

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
    authorize! :send_feedback, current_account
  end

  def send_feedback
    authorize! :send_feedback, current_account
    info = params
    puts params.inspect
    if !params[:message].blank?
      if current_account && current_account.id != 1
        info[:user_id] = current_account.id
        info[:email] = current_account.email
      end
      ApplicationMailer.feedback(info).deliver
      go_to root_path, :notice => "Your feedback has been sent. Thank you!"
    else
      add_flash :error, "Please fill in your feedback message."
      render 'feedback'
    end
  end
end
