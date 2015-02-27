class ClothingController < ApplicationController
  autocomplete :clothing, :name, :display_value => :autocomplete_view, :extra_data => [:number], :full => true
  handles_sortable_columns
  respond_to :html, :xml, :json, :csv
  # GET /clothing
  # GET /clothing.xml
  def index
    authorize! :view_clothing, current_account
    @tags = current_account.clothing.tag_counts_on(:tags).sort_by(&:name)
    order = filter_sortable_column_order %w{clothing_type name status clothing_logs_count last_worn hue}, 'name'
    logger.info order
    @clothing = current_account.clothing
    @clothing = @clothing.where("status='active' OR status IS NULL OR status=''").order(order)
    respond_with @clothing
  end

  # GET /clothing/1
  # GET /clothing/1.xml
  def show
    @clothing = current_account.clothing.find(params[:id])
    authorize! :view, @clothing
    @logs = current_account.clothing_logs.where("clothing_id=?", @clothing.id).order('date DESC')
    @previous = @clothing.previous_by_id
    @next = @clothing.next_by_id

    tags = @clothing.tag_list
    search = Array.new
    if tags.include? "bottom"
      search << "top"
    elsif tags.include? "top"
      search << "bottom"
    end
    if tags.include? "office"
      search << "office"
    elsif tags.include? "casual"
      search << "casual"
    end
    if search.size > 0 then
      matches = current_account.clothing.tagged_with(search[0])
      if search.size > 1 then
        matches = matches.tagged_with(search[1])
      end
      matches = matches.order('last_worn')
      matches = matches.where('status = ?', 'active')
      list = Hash.new
      matches.each do |m|
        list[m.id] = m
      end
    end
    @matches = Array.new
    @previous_matches = Array.new
    list ||= Hash.new
    @clothing.clothing_matches.group(:clothing_b_id).distinct.count.sort { |a,b| b[1] <=> a[1] }.each do |id, count| 
      item = current_account.clothing.find_by_id(id)
      if item and item.status == 'active'
        list[id] ||= item
        list[id].name += " (#{count})"
        @previous_matches << list[id]
      end
      list.delete(id)
    end
    if matches then
      matches.each do |m|
        if list[m.id] then
          @matches << m
        end
      end
    end
    respond_with @clothing
  end

  def clothing_logs
    @clothing = current_account.clothing.find(params[:id])
    authorize! :view, @clothing
    if request.format.html?
      redirect_to clothing_path(@clothing) and return
    end
    @logs = current_account.clothing_logs.where("clothing_id=?", @clothing.id).order('date DESC')
    respond_with @logs
  end
  
  # GET /clothing/new
  # GET /clothing/new.xml
  def new
    authorize! :create, Clothing
    @clothing = Clothing.new
    @clothing.status = 'active'
    @clothing.user_id = current_account.id
    respond_with @clothing
  end

  # GET /clothing/1/edit
  def edit
    @clothing = current_account.clothing.find(params[:id])
    authorize! :update, @clothing
  end

  # POST /clothing
  # POST /clothing.xml
  def create
    authorize! :create, Clothing
    @clothing = Clothing.new(clothing_params)
    @clothing.user_id = current_account.id
    if @clothing.save
      add_flash :notice, 'Clothing was successfully created.'
    end
    respond_with @clothing, :location => new_clothing_path
  end

  # PUT /clothing/1
  # PUT /clothing/1.xml
  def update
    @clothing = current_account.clothing.find(params[:id])
    authorize! :update, @clothing
    params[:clothing].delete(:user_id)

    if @clothing.update_attributes(clothing_params)
      add_flash :notice, 'Clothing was successfully updated.'
    end
    respond_with @clothing
  end

  # DELETE /clothing/1
  # DELETE /clothing/1.xml
  def destroy
    @clothing = current_account.clothing.find(params[:id])
    authorize! :delete, @clothing
    @clothing.destroy
    respond_with @clothing, :location => clothing_index_url
  end

  def tag
    # Show by tags
    authorize! :view_clothing, current_account
    order = filter_sortable_column_order %w{clothing_type name status clothing_logs_count last_worn hue}
    order ||= 'last_worn'
    @tags = current_account.clothing.tag_counts_on(:tags).sort_by(&:name)
    @clothing = current_account.clothing.tagged_with(params[:id]).where("status='active' or status='' or status is null").order(order)
    respond_with @clothing do |format|
      format.html { render :index }
    end
  end
  
  def by_status
    # Show by tags
    authorize! :view_clothing, current_account
    order = filter_sortable_column_order %w{clothing_type name status clothing_logs_count last_worn hue}
    @tags = current_account.clothing.tag_counts_on(:tags).sort_by(&:name)
    @status = params[:status] || 'all'
    @clothing = current_account.clothing.order(order)
    if @status != 'all' then
      @clothing = @clothing.where('status = ?', @status)
    end
    respond_with @clothing do |format|
      format.html { render :index }
    end
  end
  
  def analyze
    authorize! :view_clothing, current_account
    @start_date = params[:start] ? Date.parse(params[:start]) : (Time.zone.now.to_date - 1.week)
    @end_date = params[:end] ? Date.parse(params[:end]) : Time.zone.now.to_date
    @zoom = params[:zoom] || 'weekly'

    case @zoom
    when 'weekly'
      @step = lambda { |date| date + 7.days }
      @start_display = current_account.adjust_end_of_week(@start_date)
      @end_display = current_account.adjust_end_of_week(@end_date)
    when 'monthly'
      @step = lambda { |date| current_account.adjust_end_of_month(date + 1.day) }
      @start_display = current_account.adjust_end_of_month(@start_date)
      @end_display = current_account.adjust_end_of_month(@end_date)
    when 'yearly'
      @step = lambda { |date| current_account.adjust_end_of_year(date + 1.day) }
      @start_display = current_account.adjust_end_of_year(@start_date)
      @end_display = current_account.adjust_end_of_year(@end_date)
    else
      @step = lambda { |date| date + 1.day }
      @start_display = @start_date
      @end_display = @end_date
    end

    # Straight chart
    logs = current_account.clothing_logs.where("date >= ? AND date <= ?", @start_date, @end_date).order("date ASC")
    @clothes = Hash.new
    @logs = Hash.new
    @matches = Hash.new
    @tops = Hash.new
    bottoms = Hash.new
    tops = Hash.new

    @result = ClothingLog.summarize(records: logs, zoom: @zoom, user: current_account)

    logs.each do |l|
      @clothes[l.clothing_id] ||= current_account.clothing.find(l.clothing_id)
      tags = l.clothing.tag_list
      if (tags.include? "bottom") then
        bottoms[l.date] ||= Hash.new
        bottoms[l.date][l.outfit_id || 1] = l.clothing_id
      elsif not (tags.include? "vest" or tags.include? "sweater" or tags.include? "blazer")
        tops[l.date] ||= Hash.new
        tops[l.date][l.outfit_id || 1] = l.clothing_id
        @tops[l.clothing_id] ||= @clothes[l.clothing_id] 
      end
    end

    # Match tops and bottoms
    bottoms.each do |date, outfit|
      outfit.each do |id, clothing_id|
        @matches[clothing_id] ||= Hash.new
	if tops[date]
           @matches[clothing_id][tops[date][id] || 0] ||= Array.new
           @matches[clothing_id][tops[date][id] || 0] <<= date
        end
      end
    end
    tops.each do |date, outfit|
      outfit.each do |id, clothing_id|
        unless bottoms[date] && bottoms[date][id] 
          @matches[0] ||= Hash.new
          @matches[0][clothing_id] ||= Array.new
          @matches[0][clothing_id] <<= date
        end
      end
    end
    @sorted_matches = @matches.sort
    @tops = @tops.sort
  end

  def graph
    authorize! :view_clothing, current_account
    @start = params[:start] || current_account.clothing_logs.minimum(:date)
    @end = params[:end] || (current_account.clothing_logs.maximum(:date) + 1.day)
    @matches = ClothingMatch.prepare_graph(current_account, @start..@end)
    respond_with @matches
  end

  def bulk
    authorize! :manage_account, current_account
    if params[:bulk] and params[:op] then
      params[:bulk].compact.each do |i|
        clothing = current_account.clothing.find(i)
        case params[:op]
          when I18n.t('app.clothing.actions.store')
            clothing.status = 'stored'
            clothing.save
          when I18n.t('app.clothing.actions.activate')
            clothing.status = 'active'
            clothing.save
          when I18n.t('app.clothing.actions.donate')
            clothing.status = 'donated'
            clothing.save
          when I18n.t('app.clothing.today')
            ClothingLog.create(user: clothing.user, clothing: clothing, date: Time.zone.today).save!
          when I18n.t('app.clothing.yesterday')
            ClothingLog.create(user: clothing.user, clothing: clothing, date: Time.zone.today.yesterday).save!
          when I18n.t('app.clothing.tomorrow')
            ClothingLog.create(user: clothing.user, clothing: clothing, date: Time.zone.today.tomorrow).save!
        end
      end
    end
    redirect_to params[:destination] || clothing_index_path
  end

  def missing_info
    authorize! :manage_account, current_account
    @clothing = current_account.clothing.active.where('image_file_name IS NULL')
    respond_with @clothing
  end

  def update_missing_info
    authorize! :manage_account, current_account
    if params[:image]
      params[:image].each do |k, v|
        c = current_account.clothing.find_by_id(k)
        if c
          c.image = v
          c.save
        end
      end
    end
    @clothing = current_account.clothing.active.where("image_file_name IS NULL")
    respond_with @clothing do |format|
      format.html { render 'missing_info' }
    end
  end

  def delete_color
    authorize! :manage_account, current_account
    @clothing = current_account.clothing.find_by_id(params[:id])
    result = @clothing.delete_color(params[:color])
    if result and @clothing.save
      go_to clothing_path(@clothing), notice: 'Color removed.'
    else
      go_to clothing_path(@clothing), error: 'Could not remove color.'
    end
  end

  def save_color
    authorize! :manage_account, current_account
    @clothing = current_account.clothing.find_by_id(params[:id])
    if @clothing and params[:x] and params[:y]
      @clothing.add_color(Clothing.guess_color(@clothing.image.path(:large), params[:x], params[:y]))
      @clothing.save!
    end
    redirect_to @clothing
  end

  private
  def clothing_params
    params.require(:clothing).permit(:name, :color, :clothing_type, :notes, :labeled, :status, :hue, :saturation, :brightness, :cost, :last_worn, :tag_list, :image)
  end    
end
