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
  end
end
