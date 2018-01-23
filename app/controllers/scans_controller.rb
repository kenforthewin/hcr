class ScansController < ApplicationController
  def new
  end

  def create
    uuid = SecureRandom.urlsafe_base64
    url = params[:url]
    url.prepend('http://') unless url[0..3].downcase == 'http'

    ScanJob.perform_async(url, uuid)

    respond_to do |format|
      format.html { redirect_to scan_path(uuid) }
      format.json { render json: {uuid: uuid}.to_json }
    end
  end

  def show
    client = Elasticsearch::Client.new log: true, host: 'elasticsearch'
    respond_to do |format|
      format.json do
        @search_result = client.termvector index: 'page', id: params[:uuid], fields: ['text'], type: 'page_body'
        return render json: {ready: false }.to_json unless @search_result['term_vectors'] && @search_result['term_vectors']['text'] && @search_result['term_vectors']['text']['terms']
        term_vectors = @search_result['term_vectors']['text']['terms'].sort_by{|k, v| v['term_freq'] }.reverse.first(15)
        @search_result = term_vectors
      end
      format.html do 
        @uuid = params[:uuid]
        @url = client.get(index: 'page', id: @uuid)['_source']['url']
      end
    end
  end
end
