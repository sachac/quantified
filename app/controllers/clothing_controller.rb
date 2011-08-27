class ClothingController < ApplicationController
  autocomplete :clothing, :name, :display_value => :autocomplete_view, :extra_data => [:number], :full => true
  handles_sortable_columns

  # GET /clothing
  # GET /clothing.xml
  def index
    order = sortable_column_order
    order ||= "last_worn asc"
    @clothing = Clothing.find(:all, :select => 'clothing.*, count(clothing_logs.id) as clothing_logs_count, max(clothing_logs.date) AS last_worn',
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
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @clothing }
    end
  end

  # GET /clothing/new
  # GET /clothing/new.xml
  def new
    @clothing = Clothing.new
    @clothing.number = Clothing.maximum(:number) + 1
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
end
