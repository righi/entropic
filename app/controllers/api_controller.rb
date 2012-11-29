class ApiController < ApplicationController
  

  def uuid
    entropy = params[:entropy]
    callback = params[:callback]

    if entropy.blank?
      respond callback, 400, {error: "Required parameter 'entropy' was not provided."} 
    elsif entropy.length != 128 or !entropy.match($SHA512_REGEX)
      respond callback, 400, {error: "Parameter 'entropy' must be a valid SHA512 hash containing 128 hex characters."}
    else
      hash = $ENTROPY_POOL.mix(entropy)
      # TODO Move this to a service class for better testing and reuse
      uuid = "#{hash[0..7]}-#{hash[8..11]}-#{hash[12..15]}-#{hash[16..19]}-#{hash[20..31]}"
      respond callback, 200, {uuid: uuid}
    end
  end

  private
    def respond(callback, http_status_code, resp_obj)
      render text: "#{callback}(#{resp_obj.to_json})", status: http_status_code, content_type: 'text/javascript'
    end

end
