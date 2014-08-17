# encoding: UTF-8

require 'spec_helper'

describe JsonWriteStream::YieldingWriter do
  let(:stream) { StringIO.new }
  let(:stream_writer) { JsonWriteStream::YieldingWriter.new(stream) }

  def check_roundtrip(obj)
    YieldingRoundtripChecker.check_roundtrip(obj)
  end

  it_behaves_like 'a json stream'

  describe '#write_key_value' do
    it 'converts all keys to strings' do
      stream_writer.write_object do |object_writer|
        object_writer.write_key_value(123, 'abc')
      end

      expect(stream.string).to eq('{"123":"abc"}')
    end

    it 'supports non-string values' do
      stream_writer.write_object do |object_writer|
        object_writer.write_key_value('abc', 123)
        object_writer.write_key_value('def', true)
      end

      expect(stream.string).to eq('{"abc":123,"def":true}')
    end
  end

  describe '#close' do
    it 'closes the underlying stream' do
      stream_writer.close
      expect(stream).to be_closed
    end
  end
end
