# encoding: UTF-8

require 'spec_helper'
require 'tempfile'

describe JsonWriteStream do
  let(:yielding_writer) { JsonWriteStream::YieldingWriter }
  let(:stateful_writer) { JsonWriteStream::StatefulWriter }
  let(:stream_writer) { JsonWriteStream }
  let(:tempfile) { Tempfile.new('temp') }
  let(:stream) { StringIO.new }

  describe '#from_stream' do
    it 'yields a yielding stream if given a block' do
      stream_writer.from_stream(stream) do |writer|
        expect(writer).to be_a(yielding_writer)
        expect(writer.stream).to equal(stream)
      end
    end

    it 'returns a stateful writer if not given a block' do
      writer = stream_writer.from_stream(stream)
      expect(writer).to be_a(stateful_writer)
      expect(writer.stream).to equal(stream)
    end

    it 'supports specifying a different encoding' do
      stream_writer.from_stream(stream, Encoding::UTF_16BE) do |writer|
        writer.write_object do |obj_writer|
          obj_writer.write_key_value('foo', 'bar')
        end
      end

      expect(stream.string.bytes).to_not eq('{"foo":"bar"}'.bytes)
      expect(stream.string.encode(Encoding::UTF_8).bytes).to eq('{"foo":"bar"}'.bytes)
    end
  end

  describe '#open' do
    it 'opens a file and yields a yielding stream if given a block' do
      mock.proxy(File).open(tempfile, 'w')
      stream_writer.open(tempfile) do |writer|
        expect(writer).to be_a(yielding_writer)
        expect(writer.stream.path).to eq(tempfile.path)
      end
    end

    it 'opens a file and returns a stateful writer if not given a block' do
      mock.proxy(File).open(tempfile, 'w')
      writer = stream_writer.open(tempfile)
      expect(writer).to be_a(stateful_writer)
      expect(writer.stream.path).to eq(tempfile.path)
    end

    it 'supports specifying a different encoding' do
      stream_writer.open(tempfile, Encoding::UTF_16BE) do |writer|
        writer.write_object do |obj_writer|
          obj_writer.write_key_value('foo', 'bar')
        end
      end

      written = tempfile.read
      written.force_encoding(Encoding::UTF_16BE)

      expect(written.bytes).to_not eq('{"foo":"bar"}'.bytes)
      expect(written.encode(Encoding::UTF_8).bytes).to eq('{"foo":"bar"}'.bytes)
    end
  end
end
