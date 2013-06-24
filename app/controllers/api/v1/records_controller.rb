class Api::V1::RecordsController  < ApplicationController      
  respond_to :json, :xml
  def create          
    authorize! :manage_account, current_account
    if params[:category].blank? and params[:category_id].blank?
      status = 302
      message = {:message => 'Please specify a category.'}
    else
      rec = Record.parse(current_account, params)
      if rec.nil?
        status = 302 
        message = {:message => 'Could not find matching category.'}
      elsif rec.is_a? Record
        status = 200
        message = rec
      else
        status = 302
        data = Record.guess_time(params[:category])
        @list = RecordCategory.search(current_account, data[0])
        time = data[1]
        end_time = data[2]
        unless params[:timestamp].blank?
          time ||= params[:timestamp]
        end
        time ||= Time.now
        status = 302
        message = {:message => 'Please disambiguate', :list => @list, :time => time}
      end
    end
    respond_to do |format|
      format.json { render(:status => status, :json => message) and return }
      format.xml { render(:status => status, :xml => message) and return }
    end
  end
end
