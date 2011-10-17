class ClothingController < ApplicationController
  autocomplete :clothing, :name, :display_value => :autocomplete_view, :extra_data => [:number], :full => true
  handles_sortable_columns
  before_filter :authenticate_user!, :except => [:index, :tag, :show, :analyze]

  # GET /clothing
  # GET /clothing.xml
  def index
    @tags = Clothing.tag_counts_on(:tags).sort_by(&:name)
    order = sortable_column_order
    order ||= "clothing_type asc, hue asc"
    @clothing = Clothing.find(:all, 
                              :conditions => ["status is null OR status != 'donated'"],
                              :select => 'clothing.*, count(clothing_logs.id) as clothing_logs_count, max(clothing_logs.date) AS last_worn',
                              :joins => 'left outer join clothing_logs ON clothing.id=clothing_logs.clothing_id', :group => 'clothing.id', :order => order)

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
      @matches = Clothing.tagged_with(search[0])
      if (search.size > 1) then
        @matches = @matches.tagged_with(search[1])
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
    @clothing.number = Clothing.maximum(:id) + 1
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
        format.html { redirect_to(@clothing, :notice => 'Clothing was successfully updated.') }
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
    @clothing = Clothing.tagged_with(params[:id]).joins('left outer join clothing_logs ON clothing.id=clothing_logs.clothing_id').select('clothing.*, count(clothing_logs.id) as clothing_logs_count, max(clothing_logs.date) AS last_worn').group('clothing.id').order(order)
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
end
