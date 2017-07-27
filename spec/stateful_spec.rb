# encoding: UTF-8

require 'spec_helper'

describe JsonWriteStream::YieldingWriter do
  let(:stream) do
    StringIO.new.tap do |io|
      io.set_encoding(Encoding::UTF_8)
    end
  end

  let(:stream_writer) { JsonWriteStream::StatefulWriter.new(stream) }

  def check_roundtrip(obj)
    StatefulRoundtripChecker.check_roundtrip(obj)
  end

  def utf8(str)
    str.encode(Encoding::UTF_8)
  end

  it_behaves_like 'a json stream'

  it 'respects the "before" option' do
    stream_writer.write_object
    stream_writer.write_key_value('foo', 'bar', before: "\n  ")
    stream_writer.close

    expect(stream.string).to eq("{\n  \"foo\":\"bar\"}")
  end

  it 'respects the "between" option' do
    stream_writer.write_object
    stream_writer.write_key_value('foo', 'bar', between: ' ')
    stream_writer.close

    expect(stream.string).to eq('{"foo": "bar"}')
  end

  describe '#close' do
    it 'unwinds the stack, adds appropriate closing punctuation for each unclosed item, and closes the stream' do
      stream_writer.write_array
      stream_writer.write_element('abc')
      stream_writer.write_object
      stream_writer.write_key_value('def', 'ghi')
      stream_writer.close

      expect(stream.string).to eq(utf8('["abc",{"def":"ghi"}]'))
      expect(stream_writer).to be_closed
      expect(stream).to be_closed
    end
  end

  describe '#closed?' do
    it 'returns false if the stream is still open' do
      expect(stream_writer).to_not be_closed
    end

    it 'returns true if the stream is closed' do
      stream_writer.close
      expect(stream_writer).to be_closed
    end
  end

  describe '#in_object?' do
    it 'returns true if the writer is currently writing an object' do
      stream_writer.write_object
      expect(stream_writer).to be_in_object
    end

    it 'returns false if the writer is not currently writing an object' do
      expect(stream_writer).to_not be_in_object
      stream_writer.write_array
      expect(stream_writer).to_not be_in_object
    end
  end

  describe '#in_array?' do
    it 'returns true if the writer is currently writing an array' do
      stream_writer.write_array
      expect(stream_writer).to be_in_array
    end

    it 'returns false if the writer is not currently writing an array' do
      expect(stream_writer).to_not be_in_array
      stream_writer.write_object
      expect(stream_writer).to_not be_in_array
    end
  end

  describe '#eos?' do
    it 'returns false if nothing has been written yet' do
      expect(stream_writer).to_not be_eos
    end

    it 'returns false if the writer is in the middle of writing' do
      stream_writer.write_object
      expect(stream_writer).to_not be_eos
    end

    it "returns true if the writer has finished it's top-level" do
      stream_writer.write_object
      stream_writer.close_object
      expect(stream_writer).to be_eos
    end

    it 'returns true if the writer is closed' do
      stream_writer.close
      expect(stream_writer).to be_eos
    end
  end

  describe '#close_object' do
    it 'raises an error if an object is not currently being written' do
      stream_writer.write_array
      expect(-> { stream_writer.close_object }).to raise_error(JsonWriteStream::NotInObjectError)
    end
  end

  describe '#close_array' do
    it 'raises an error if an array is not currently being written' do
      stream_writer.write_object
      expect(-> { stream_writer.close_array }).to raise_error(JsonWriteStream::NotInArrayError)
    end
  end

  context 'with a closed stream writer' do
    before(:each) do
      stream_writer.close
    end

    describe '#write_object' do
      it 'raises an error if eos' do
        expect(-> { stream_writer.write_object }).to raise_error(JsonWriteStream::EndOfStreamError)
      end
    end

    describe '#write_array' do
      it 'raises an error if eos' do
        expect(-> { stream_writer.write_object }).to raise_error(JsonWriteStream::EndOfStreamError)
      end
    end

    describe '#write_key_value' do
      it 'raises an error if eos' do
        expect(-> { stream_writer.write_key_value('abc', 'def') }).to raise_error(JsonWriteStream::EndOfStreamError)
      end
    end

    describe '#write_element' do
      it 'raises an error if eos' do
        expect(-> { stream_writer.write_element('foo') }).to raise_error(JsonWriteStream::EndOfStreamError)
      end
    end
  end
end
