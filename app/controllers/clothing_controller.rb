class ClothingController < ApplicationController
  autocomplete :clothing, :name, :display_value => :autocomplete_view, :extra_data => [:number], :full => true
  handles_sortable_columns

  # GET /clothing
  # GET /clothing.xml
  def index
    authorize! :view_clothing, current_account
    @tags = current_account.clothing.tag_counts_on(:tags).sort_by(&:name)
    order = filter_sortable_column_order %w{clothing_type name status clothing_logs_count last_worn hue}
    @clothing = current_account.clothing
    @clothing = @clothing.find(:all, 
                               :conditions => ["status='active' OR status IS NULL OR status=''"],
                               :order => order)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @clothing }
    end
  end

  # GET /clothing/1
  # GET /clothing/1.xml
  def show
    @clothing = current_account.clothing.find(params[:id])
    authorize! :view, @clothing
    @logs = current_account.clothing_logs.find(:all, :conditions => ["clothing_id=?", @clothing.id], :order => 'date DESC')
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
    @past_matches = @clothing.clothing_matches.count(:group => :clothing_b_id).sort { |a,b| b[1] <=> a[1] }.each do |id, count| 
      item = current_account.clothing.find_by_id(id)
      if item
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
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @clothing }
    end
  end

  # GET /clothing/new
  # GET /clothing/new.xml
  def new
    authorize! :create, Clothing
    @clothing = Clothing.new
    @clothing.status = 'active'
    @clothing.user_id = current_account.id
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @clothing }
    end
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
    @clothing = Clothing.new(params[:clothing])
    @clothing.user_id = current_account.id
    respond_to do |format|
      if @clothing.save
        format.html { redirect_to(new_clothing_path, :notice => 'Clothing was successfully created.') }
        format.xml  { render :xml => @clothing, :status => :created, :location => @clothing }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @clothing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /clothing/1
  # PUT /clothing/1.xml
  def update
    @clothing = current_account.clothing.find(params[:id])
    authorize! :update, @clothing
    respond_to do |format|
      if @clothing.update_attributes(params[:clothing])
        format.html { redirect_to(clothing_path(@clothing), :notice => 'Clothing was successfully updated.') and return }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @clothing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /clothing/1
  # DELETE /clothing/1.xml
  def destroy
    @clothing = current_account.clothing.find(params[:id])
    authorize! :delete, @clothing
    @clothing.destroy

    respond_to do |format|
      format.html { redirect_to(clothing_index_url) }
      format.xml  { head :ok }
    end
  end

  def tag
    # Show by tags
    authorize! :view_clothing, current_account
    order = filter_sortable_column_order %w{clothing_type name status clothing_logs_count last_worn hue}
    @tags = current_account.clothing.tag_counts_on(:tags).sort_by(&:name)
    @clothing = current_account.clothing.tagged_with(params[:id]).where("status='active' or status='' or status is null").order(order)
    render :index
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
    render :index
  end
  
  def analyze
    authorize! :view_clothing, current_account
    @start_date = params[:start] ? Date.parse(params[:start]) : (Date.today - 1.week)
    @end_date = params[:end] ? Date.parse(params[:end]) : Date.today
    # Straight chart
    logs = current_account.clothing_logs.where("date >= ? AND date <= ?", @start_date, @end_date).order("date ASC")
    logger.info "CLOTHING LOGS: " + logs.inspect
    @clothes = Hash.new
    @logs = Hash.new
    @matches = Hash.new
    @tops = Hash.new
    bottoms = Hash.new
    tops = Hash.new
    logs.each do |l|
      @clothes[l.clothing_id] ||= current_account.clothing.find(l.clothing_id)
      @logs[l.clothing_id] ||= Hash.new
      @logs[l.clothing_id][l.date] = l
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
    # Create a bipartite graph of tops and bottoms
    @tops = current_account.clothing.tagged_with('top')
    @bottoms = current_account.clothing.tagged_with('bottom')
    @start = params[:start] || current_account.clothing_logs.minimum(:date)
    @end = params[:end] || current_account.clothing_logs.maximum(:date)
    @matches = current_account.clothing_matches.joins('INNER JOIN clothing_logs ON clothing_log_a_id = clothing_logs.id').where('clothing_a_id < clothing_b_id AND clothing_logs.date >= ? AND clothing_logs.date <= ?', @start, @end).count(:group => ['clothing_a_id', 'clothing_b_id'])
  end

  def bulk
    authorize! :manage, current_account
    if params[:bulk] and params[:op] then
      params[:bulk].compact.each do |i|
        clothing = current_account.clothing.find(i)
        case params[:op]
          when I18n.t('app.clothing.actions.store')
            clothing.status = 'stored'
          when I18n.t('app.clothing.actions.activate')
            clothing.status = 'active'
          when I18n.t('app.clothing.actions.donate')
            clothing.status = 'donated'
        end
        clothing.save
      end
    end
    redirect_to params[:destination] || clothing_index_path
  end

  def missing_info
    authorize! :manage_account, current_account
    @clothing = current_account.clothing.active.where('image_file_name IS NULL')
  end

  def update_missing_info
    authorize! :manage_account, current_account
    if params[:image]
      params[:image].each do |k, v|
        c = current_account.clothing.find_by_id(c)
        if c
          c.image = v
          c.save
        end
      end
    end
    @clothing = current_account.clothing.active.where("image_file_name IS NULL")
    render 'missing_info'
  end

  def delete_color
    authorize! :manage_account, current_account
    @clothing = current_account.clothing.find_by_id(params[:id])
    colors = (@clothing.color || '').split /,/
    result = colors.delete(params[:color])
    if result and @clothing.update_attributes(:color => colors.join(','))
      go_to clothing_path(@clothing), :notice => 'Colour removed.'
    else
      go_to clothing_path(@clothing), :error => 'Could not remove colour.'
    end
  end

  def save_color
    authorize! :manage_account, current_account
    @clothing = current_account.clothing.find_by_id(params[:id])
    if @clothing and params[:x] and params[:y]
      if @clothing.color.blank?
        @clothing.color = Clothing.guess_color(@clothing.image, params[:x], params[:y])
      else
        @clothing.color += ',' + Clothing.guess_color(@clothing.image, params[:x], params[:y])
      end
      @clothing.save!
    end
    redirect_to @clothing

  end

  
  def download_thumbnail
    @clothing = current_account.clothing.find(params[:id])
    authorize! :view, @clothing
    # response.headers['X-Accel-Redirect'] = 'files' + @clothing.image.url
    # response.headers['Content-Type'] = @clothing.image_content_type
    # response.headers['Content-Disposition'] = "inline; filename=#{@clothing.image_file_name}"
    # logger.info response.headers.inspect
    # # #Make sure we don't render anything
    # render :nothing => true 
    logger.info @clothing.image.path(params[:style])
    send_file @clothing.image.path(params[:style]), :type => @clothing.image_content_type, :disposition => 'inline' 
  end

end
