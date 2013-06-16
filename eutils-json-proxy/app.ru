require 'uri'
require 'open-uri'
require 'nori'
require 'json'

app = lambda do |env|
  req = Rack::Request.new(env)
  parser = Nori.new
  req.update_param('retmode','xml')
  params = Array.new
  req.params().each do |k,v|
    params.push("#{k}=#{v}")
  end
  query_string=URI.escape(params.join("&"))
  eutils = "http://eutils.ncbi.nlm.nih.gov" + req.path()+"?"+query_string
  begin
    res = URI.parse(eutils).read
    h = parser.parse(res)
    h["status"]="ok"
    body = h.to_json
    [200, {"Content-Type" => "application/json", "Content-Length" => body.length.to_s}, [body]]
  rescue OpenURI::HTTPError => e
    body = {"status"=>"error","message" => e.message}.to_json
    [200, {"Content-Type" => "application/json", "Content-Length" => body.length.to_s}, [body]]
  rescue URI::InvalidURIError => e
    body = {"status"=>"error","message" => e.message}.to_json
    [200, {"Content-Type" => "application/json", "Content-Length" => body.length.to_s}, [body]]
  end
end
 
run app
