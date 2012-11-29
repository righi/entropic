class ApiController < ApplicationController
  

  def uuid
    entropy = params[:entropy]
    callback = params[:callback]

    if entropy.blank?
      respond callback, 400, {error: "Required parameter 'entropy' was not provided."} 
    elsif entropy.length != 128 or !entropy.match(SHA512_REGEX)
      respond callback, 400, {error: "Parameter 'entropy' must be a valid SHA512 hash containing 128 hex characters."}
    else
      # TODO Implement real code here
      uuid = "550e8400-e29b-41d4-a716-446655440000"
      respond callback, 200, {uuid: uuid}
    end
  end

  private
    def respond(callback, http_status_code, resp_obj)
      render text: "#{callback}(#{resp_obj.to_json})", status: http_status_code, content_type: 'text/javascript'
    end

end
