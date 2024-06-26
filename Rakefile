require './lib/extract_carousel_data.rb'

task default: %w[van_gogh]

desc "[default] parses: files/van-gogh-paintings.html, and creates json: output/van-gogh-paintings.json"
task :van_gogh do
  puts("Parsing 'files/van-gogh-paintings.html' ...")
  obj = ExtractCarouselData.new
  doc = obj.get_document
  data = obj.parse_carousel(doc)
  obj.write_json(data)
  puts("Done. See 'output/van-gogh-paintings.json'")
end

desc "parses: input/paul-signac-paintings.html, and creates json: output/paul-signac-paintings.json"
task :paul_signac do
  puts("Parsing 'input/paul-signac-paintings.html' ...")
  obj = ExtractCarouselData.new(
    input: "input/paul-signac-paintings.html",
    output: "output/paul-signac-paintings.json",
    type: :current)
  doc = obj.get_document
  data = obj.parse_carousel(doc)
  obj.write_json(data)
  puts("Done. See 'output/paul-signac-paintings.json'")
end

desc "parses: input/spider-man-movies.html, and creates json: output/spider-man-movies.json"
task :spider_man do
  puts("Parsing 'input/spider-man-movies.html' ...")
  obj = ExtractCarouselData.new(
    input: "input/spider-man-movies.html",
    output: "output/spider-man-movies.json",
    type: :current)
  doc = obj.get_document
  data = obj.parse_carousel(doc)
  obj.write_json(data)
  puts("Done. See 'output/spider-man-movies.json'")
end

