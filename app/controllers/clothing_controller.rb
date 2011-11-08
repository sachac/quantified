class ClothingController < ApplicationController
  autocomplete :clothing, :name, :display_value => :autocomplete_view, :extra_data => [:number], :full => true
  handles_sortable_columns
  before_filter :authenticate_user!, :except => [:index, :tag, :show, :analyze]

  # GET /clothing
  # GET /clothing.xml
  def index
    @tags = Clothing.tag_counts_on(:tags).sort_by(&:name)
    params[:sort] ||= 'clothing_type'
    order = sortable_column_order do |column, direction|
      case column 
      when 'name', 'status', 'clothing_logs_count', 'last_worn', 'hue'
        "#{column} #{direction}"
      else
        "clothing_type ASC, hue ASC"
      end
    end
    @clothing = Clothing.find(:all, 
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
    @clothing = Clothing.find(params[:id])
    @logs = ClothingLog.find(:all, :conditions => ["clothing_id=?", @clothing.id], :order => 'date DESC')
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
      matches = Clothing.tagged_with(search[0])
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
      list[id] ||= Clothing.find(id)
      list[id].name += " (#{count})"
      @previous_matches << list[id]
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
    @clothing = Clothing.new
    @clothing.status = 'active'
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @clothing }
    end
  end

  # GET /clothing/1/edit
  def edit
    @clothing = Clothing.find(params[:id])
  end

  # POST /clothing
  # POST /clothing.xml
  def create
    @clothing = Clothing.new(params[:clothing])

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
    @clothing = Clothing.find(params[:id])

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
    @clothing = Clothing.find(params[:id])
    @clothing.destroy

    respond_to do |format|
      format.html { redirect_to(clothing_index_url) }
      format.xml  { head :ok }
    end
  end

  def tag
    # Show by tags
    order = sortable_column_order
    order ||= "clothing_type asc, last_worn asc"
    @tags = Clothing.tag_counts_on(:tags).sort_by(&:name)
    @clothing = Clothing.tagged_with(params[:id]).where("status='active' or status='' or status is null").order(order)
    render :index
  end
  
  def by_status
    # Show by tags
    order = sortable_column_order
    order ||= "clothing_type asc, last_worn asc"
    @tags = Clothing.tag_counts_on(:tags).sort_by(&:name)
    @status = params[:status] || 'all'
    @clothing = Clothing.order(order)
    if @status != 'all' then
      @clothing = @clothing.where('status = ?', @status)
    end
    render :index
  end
  
  def analyze
    @start_date = params[:start] ? Date.parse(params[:start]) : (Date.today - 1.week)
    @end_date = params[:end] ? Date.parse(params[:end]) : Date.today
    # Straight chart
    logs = ClothingLog.where("date >= ? AND date <= ?", @start_date, @end_date).order("date ASC")
    @clothes = Hash.new
    @logs = Hash.new
    @matches = Hash.new
    @tops = Hash.new
    bottoms = Hash.new
    tops = Hash.new
    logs.each do |l|
      @clothes[l.clothing_id] ||= Clothing.find(l.clothing_id)
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
        @matches[clothing_id][tops[date][id] || 0] ||= Array.new
        @matches[clothing_id][tops[date][id] || 0] <<= date
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
    @matches = @matches.sort
    @tops = @tops.sort
  end

  def graph
    # Create a bipartite graph of tops and bottoms
    @tops = Clothing.tagged_with('top')
    @bottoms = Clothing.tagged_with('bottom')
    @start = params[:start] || ClothingLog.minimum(:date)
    @end = params[:end] || ClothingLog.maximum(:date)
    @matches = ClothingMatch.joins('INNER JOIN clothing_logs ON clothing_log_a_id = clothing_logs.id').where('clothing_a_id < clothing_b_id AND clothing_logs.date >= ? AND clothing_logs.date <= ?', @start, @end).count(:group => ['clothing_a_id', 'clothing_b_id'])
  end

  def bulk
    if params[:bulk] and params[:op] then
      params[:bulk].compact.each do |i|
        clothing = Clothing.find(i)
        case params[:op]
          when 'Store'
            clothing.status = 'stored'
          when 'Activate'
            clothing.status = 'active'
          when 'Donate'
            clothing.status = 'donated'
        end
        clothing.save
      end
    end
    redirect_to :back and return
  end
end
