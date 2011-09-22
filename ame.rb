require 'open-uri'

get '/' do
  if params[:latitude] && params[:longtitude]
    url = 'http://tokyo-ame.jwa.or.jp/mesh/100/%s.gif' %
      Time.at((Time.now - 30).to_i / 300 * 300).strftime('%Y%m%d%H%M')
    intensity = -1
    x = (params[:longtitude].to_f - 138.4) / 2.14
    y = (36.23 - params[:latitude].to_f) / 1.13

    if [x, y].all? {|n| (0...1).include? n }
      image = Magick::Image.read(open(url).to_path).first
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

    content_type 'text/plain'
    intensity.to_s
  else
    <<-HTML.gsub(/^\s*/, '')
    <title>ame</title>
    <h1>Rainfall Intensity around Tokyo</h1>
    <p>http://ame.heroku.com/?latitude=xxx&longtitude=xxx</p>
    HTML
  end
end
