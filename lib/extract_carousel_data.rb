# frozen_string_literal: true

require 'json'
require 'nokogiri'

class ExtractCarouselData
  CSS_NAMES = {
    previous: {
      carousel: "wqBQjd",
      name: "kltat",
      extensions: "ellip klmeta"
    },
    current: {
      carousel: "sfS5Re",
      name_ext: "FozYP",
      name_parent: nil,
      ext_parent: "cp7THd"
    }
  }

  attr_accessor :input, :output, :type

  def initialize(params = {})
    @input = params.fetch(:input, 'files/van-gogh-paintings.html')
    @output = params.fetch(:output, 'output/van-gogh-paintings.json')
    @type = params.fetch(:type, :previous)
    @css_names = CSS_NAMES[@type]
    @location = @type == :previous ? "https://www.google.com" : ""
  end

  def get_document
    content = File.read(File.expand_path(input))
    Nokogiri::HTML.parse(content)
  rescue
    raise RuntimeError.new("#{input} does not exist, or something went wrong")
  end

  def parse_carousel(doc)
    img_srcs = get_img_srcs(doc)
    carousel = doc.xpath("//g-scrolling-carousel[@class='#{@css_names[:carousel]}']")
    artworks = carousel.first.xpath('.//a')
    data = []
    artworks.each do |artwork|
      if type == :previous
        item = get_name_ext_previous(artwork)
      elsif type == :current
        item = get_name_ext_current(artwork)
      else
        item = {}
      end
      item = item.merge(get_link(artwork))
      item = item.merge(get_image(artwork, img_srcs))
      data << item
    end
    { "artworks": data }
  rescue
    raise RuntimeError.new("something went wrong while parsing a carousel")
  end

  def write_json(data)
    File.open(File.expand_path(output), 'w') do |f|
      f.write(JSON.pretty_generate(data))
    end
  rescue
    raise RuntimeError.new("something went wrong while writing the json data to #{output}")
  end

  def to_s
    "input: #{File.expand_path(input)}, output: #{File.expand_path(output)}, type: #{type}, css: #{@css_names.inspect}"
  end

  private

  def get_img_srcs(doc)
    scripts = doc.xpath('//script')
    imgs = scripts.select {|script| script.text.match?(/var\ss\s?=\s?'data:image/)}
    matched = []
    imgs.each do |img|
      matched << img.text.scan(/var\ss\s?=\s?'(.*?)';\n?\s*var\sii\s?=\s?\['(.*?)'\];/)
    end
    img_srcs = {}
    matched.each do |ary|
      ary.each do |a|
        if a.size == 2
          img_srcs[a[1]] = a[0]
        end
      end
    end
    img_srcs
  end

  def get_name_ext_previous(artwork)
    name_ext = { name: artwork.xpath(".//div[@class='#{@css_names[:name]}']//span").text }
    ext = artwork.xpath(".//div[@class='#{@css_names[:extensions]}']").text
    name_ext[:extensions] = [ ext ] if ext.size > 0
    name_ext
  end

  def get_name_ext_current(artwork)
    names, exts = [], []
    artwork.xpath(".//div[@class='#{@css_names[:name_ext]}']").each do |node|
      if node.parent["class"] == @css_names[:ext_parent]
        exts << node.text.strip
      elsif node.parent["class"] == @css_names[:name_parent]
        names << node.text.split(' ').map(&:strip).join(' ')
      end
    end
    name_ext = { name: names.join(' ') }
    name_ext[:extensions] = exts if exts.size > 0
    name_ext
  end

  def get_link(artwork)
    { link: "#{@location}#{artwork['href']}" }
  end

  def get_image(artwork, img_srcs)
    if artwork.xpath(".//g-img//img").first
      img_id = artwork.xpath(".//g-img//img").first["id"]
      if img_id && img_srcs[img_id]
        return { image: img_srcs[img_id] }
      end
    end
    { image: nil }
  end
end
