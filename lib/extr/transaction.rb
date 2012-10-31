module Extr

 class Transaction

  include ActiveModel::Validations

  validates :action, :presence => true
  validates :method, :presence => true
  validates :tid, :presence => true, :numericality => {:greater_than => 0}

  attr_reader :request, :action, :method, :data, :tid, :upload

  def initialize(request, action, method, tid, data, upload)
   @request = request
   @action = action
   @method = method
   @data = data
   @tid = tid
   @upload = upload
  end


  def uploadable?
   @upload ? true : false
  end

  def response
   invoke_controller_method
  end

  private

  def invoke_controller_method

   ext = {
    'type'    => 'rpc',
    'tid'     => self.tid,
    'action'  => self.action,
    'method'  => self.method,
    'result'  => ""
   }

   begin

    controller_klass = Config.get_controller_path(self.action).constantize
    token = get_token(controller_klass)

    unless controller_klass.mimes_for_respond_to.key?(Mime::JSON.symbol)
     if Rails.env.development?
      raise "For supporting the rails way define respond_to :json in your controller"
     end
    end

    #ext_params = HashWithIndifferentAccess.new
    #ext_params[controller_klass.request_forgery_protection_token] = token
    #self.request.env["action_dispatch.request.parameters"] = ext_params

    if self.uploadable?
     controller_klass.headers["Content-Type"] = "text/html"
    end

    body = controller_klass.action(self.method).call(self.request.env).to_a.last.body
    ext['result'] = body.empty? ? "" : ActiveSupport::JSON.decode(body)

    if self.uploadable?
      ext['result'] = '<html><body><textarea>'+ext['result'].to_s+'</textarea></body></html>'
    end

   rescue => e
    if Rails.env.development?
     Rails.logger.error ext['type'] = 'exception'
     Rails.logger.error ext['message'] = e.message
     Rails.logger.error ext['where'] = e.backtrace.join("\n")
    end
   ensure
    return ext
   end

  end

  private

  def get_token(controller)
   request.env["action_dispatch.request.parameters"][controller.request_forgery_protection_token] ||=   request.env["action_dispatch.request.parameters"][:_json].first[controller.request_forgery_protection_token]
  end

 end

end

