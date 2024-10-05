class MemoriesController < ApplicationController
  respond_to :html, :xml, :json, :csv
  # GET /memories
  # GET /memories.xml
  def index
    authorize! :view_memories, current_account
    if can? :manage_account, current_account
      @memories = current_account.memories
    else
      @memories = current_account.memories.where('access=?', 'public')
    end
    order = filter_sortable_column_order %w{sort_time name}
    order ||= '-sort_time'
    @tags = @memories.tag_counts_on(:tags).sort_by(&:name)
    if params[:tag] 
      @memories = @memories.tagged_with(params[:tag])
    end
    @memories = @memories.order(order)
    respond_with @memories
  end

  # GET /memories/1
  # GET /memories/1.xml
  def show
    @memory = current_account.memories.find(params[:id])
    authorize! :view, @memory
    respond_with @memory
  end

  # GET /memories/new
  # GET /memories/new.xml
  def new
    authorize! :create, Memory
    @memory = current_account.memories.new
    @memory.access = 'public'
    respond_with @memory
  end

  # GET /memories/1/edit
  def edit
    @memory = current_account.memories.find(params[:id])
    authorize! :update, @memory
  end

  # POST /memories
  # POST /memories.xml
  def create
    @memory = current_account.memories.new(memory_params[:memory])
    authorize! :create, Memory
    @memory.user = current_account
    if @memory.save
      add_flash :notice, 'Memory was successfully created.'
      respond_with @memory, :location => params[:destination].blank? ? memories_path : params[:destination]
    else
      respond_with @memory
    end
  end

  # PUT /memories/1
  # PUT /memories/1.xml
  def update
    @memory = current_account.memories.find(params[:id])
    authorize! :update, @memory
    params[:memory].delete(:user_id)
    if @memory.update_attributes(memory_params[:memory])
      add_flash :notice, 'Memory was successfully updated.'
      respond_with @memory, :location => memories_path
    else
      respond_with @memory
    end
  end

  # DELETE /memories/1
  # DELETE /memories/1.xml
  def destroy
    @memory = current_account.memories.find(params[:id])
    authorize! :delete, @memory
    @memory.destroy

    respond_to do |format|
      format.html { go_to(memories_url) }
      format.any  { head :ok }
    end
  end

  private
  def memory_params
    params.permit(:memory => [:name, :body, :access, :timestamp, :rating, :date_entry, :sort_time])
  end
end
