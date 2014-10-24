class DecisionLogsController < ApplicationController
  # GET /decision_logs
  # GET /decision_logs.xml
  load_and_authorize_resource
  respond_to :html, :json, :xml, :csv
  def index
    authorize! :manage_account, current_account
    @decision_logs = current_account.decision_logs
    respond_with @decision_logs
  end

  # GET /decision_logs/1
  # GET /decision_logs/1.xml
  def show
    respond_with @decision_log
  end

  # GET /decision_logs/new
  # GET /decision_logs/new.xml
  def new
    @decision_log.date = Time.zone.now.to_date
    if params[:decision_id] then
      @decision_log.decision_id = params[:decision_id]
    end
    @decision_log.user_id = current_account.id
    respond_with @decision_log
  end

  # GET /decision_logs/1/edit
  def edit
    respond_with @decision_log
  end

  # POST /decision_logs
  # POST /decision_logs.xml
  def create
    authorize! :manage_account, current_account
    @decision_log = current_account.decision_logs.new(decision_log_params)
    if @decision_log.save
      add_flash :notice, I18n.t('decision_log.created')
    end
    respond_with @decision_log
  end

  # PUT /decision_logs/1
  # PUT /decision_logs/1.xml
  def update
    @decision_log = current_account.decision_logs.find(params[:id])
    params[:decision_log].delete(:user_id)
    if @decision_log.update_attributes(decision_log_params)
      add_flash :notice, I18n.t('decision_log.updated')
    end
    respond_with @decision_log
  end

  # DELETE /decision_logs/1
  # DELETE /decision_logs/1.xml
  def destroy
    @decision_log.destroy
    respond_to do |format|
      format.html { redirect_to(decision_logs_url) }
      format.any  { head :ok }
    end
  end

  private
  def decision_log_params
    params.permit(:decision, :notes, :decision_id)
  end
end
