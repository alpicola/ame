require 'open-uri/cached'
require 'active_support/time'

class << OpenURI::Cache
  attr_accessor :cache_path
end
OpenURI::Cache.cache_path = './tmp'

get '/' do
  haml :index
end

get '/intensity' do
  url = 'http://tokyo-ame.jwa.or.jp/mesh/100/%s.gif' %
    Time.at((Time.now - 30).to_i / 300 * 300).in_time_zone('Tokyo').strftime('%Y%m%d%H%M')
  intensity = -1

  if params[:latitude] && params[:longitude]
    x = (params[:longitude].to_f - 138.4) / 2.14
    y = (36.23 - params[:latitude].to_f) / 1.13

    if [x, y].all? {|n| (0...1).include? n }
      image = Magick::Image.from_blob(URI.parse(url).read).first
      x = (x * image.columns).to_i
      y = (y * image.rows).to_i
      pixel = image.pixel_color(x, y)
      pixel = image.pixel_color(x-1, y-1) if pixel.to_color == 'black'

      if pixel.opacity == 0
        pixel = (pixel.red & 0xff) << 16 | (pixel.green & 0xff) << 8 | pixel.blue & 0xff
        intensity = [0xccffff, 0x6699ff, 0x33ffff, 0x00ff00,
          0xffff00, 0xff9900, 0xff00ff, 0xff0000].index(pixel) + 1
      else
        intensity = 0
      end
    end
  end

  content_type 'text/plain'
  intensity.to_s
end
