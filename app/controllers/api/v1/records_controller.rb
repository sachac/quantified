class Api::V1::RecordsController  < ApplicationController      
  respond_to :json, :xml
  def create          
    authorize! :create, TapLogRecord
    rec = TapLogRecord.new(params[:record])
    rec.user = current_account
    rec.timestamp ||= Time.now
    if rec.save!
      status = 200
      message = rec
    else
      status = 302
      message = {:message => "Could not be saved"}
    end
    respond_to do |format|
      format.json { render(:status => status, :json => message) and return }
      format.xml { render(:status => status, :xml => message) and return }
    end
    return
  end
end
