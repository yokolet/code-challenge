# frozen_string_literal: true

require 'extract_carousel_data'

RSpec.describe ExtractCarouselData do
  context 'with van-gogh-paintings' do
    let!(:subject) { ExtractCarouselData.new }

    it 'returns document root' do
      doc = subject.get_document
      expect(doc).to be_a(Nokogiri::HTML::Document)
    end

    describe 'with document' do
      let!(:parsed_data) {
        doc = subject.get_document
        subject.parse_carousel(doc)[:artworks]
      }
      let!(:expected_array) {
        JSON.load_file(File.expand_path("files/expected-array.json"))["artworks"]
      }

      it 'returns parsed data' do
        expect(parsed_data).not_to be_nil
      end

      it 'has the same number of items' do
        expect(parsed_data.size).to eq(expected_array.size)
      end

      context 'for a specific item' do
        let!(:item0) { parsed_data[0] }
        let!(:expected0) { expected_array[0] }

        it 'has the same name' do
          expect(item0[:name]).to eq(expected0["name"])
        end

        it 'has the same extensions' do
          expect(item0[:extensions]).to match_array(expected0["extensions"])
        end

        it 'has the same links' do
          expect(item0[:link]).to eq(expected0["link"])
        end

        it 'has the same images' do
          expect(item0[:image][0...100]).to eq(expected0["image"][0...100])
        end
      end

      context 'for a specific item without extensions' do
        let!(:item2) { parsed_data[2] }
        let!(:expected2) { expected_array[2] }

        it 'has the same name' do
          expect(item2[:name]).to eq(expected2["name"])
        end

        it 'has the same extensions' do
          expect(item2[:extensions]).to be_nil
        end

        it 'has the same links' do
          expect(item2[:link]).to eq(expected2["link"])
        end

        it 'has the same images' do
          expect(item2[:image][0...100]).to eq(expected2["image"][0...100])
        end
      end
    end
  end

  context 'with paul-signac-paintings' do
    let!(:subject) {
      ExtractCarouselData.new(
        input: "input/paul-signac-paintings.html",
        output: "output/paul-signac-output.json",
        type: :current)
    }

    it 'returns document root' do
      doc = subject.get_document
      expect(doc).to be_a(Nokogiri::HTML::Document)
    end

    describe 'with document' do
      let!(:doc) { subject.get_document }

      it 'returns parsed data' do
        parsed_data = subject.parse_carousel(doc)
        expect(parsed_data).not_to be_nil
        expect(parsed_data[:artworks].size).to be > 0
      end
    end
  end
end
