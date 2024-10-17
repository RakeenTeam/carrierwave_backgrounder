require 'spec_helper'
require 'support/mock_worker'

module CarrierWave::Backgrounder
  RSpec.describe Support::Backends do
    let(:mock_module) { Module.new }

    before do
      mock_module.send :include, Support::Backends
    end

    describe 'setting backend' do
      it 'using #backend=' do
        expect {
          mock_module.backend = :solid_queue
        }.to raise_error(NoMethodError)
      end

      it 'using #backend' do
        mock_module.backend(:solid_queue)
        expect(mock_module.backend).to eql(:solid_queue)
      end

      it 'allows passing of queue_options' do
        mock_module.backend(:solid_queue, :queue => :important_queue)
        expect(mock_module.queue_options).to eql({:queue => :important_queue})
      end
    end

    describe '#enqueue_for_backend' do
      let!(:worker) { MockWorker.new('FakeClass', 1, :image) }

      context 'solid_queue' do
        let(:args) { ['FakeClass', 1, :image] }

        it 'invokes SolidQueue.enqueue with string arguments' do
          expect(SolidQueue).to receive(:enqueue).with('FakeClass', '1', 'image')
          mock_module.backend :solid_queue
          mock_module.enqueue_for_backend(SolidQueue, *args)
        end

        it 'invokes enqueue and includes the options passed to backend' do
          expect(SolidQueue).to receive(:enqueue).with('FakeClass', '1', 'image', retry: false, timeout: 60, queue: :important_queue)
          options = { retry: false, timeout: 60, queue: :important_queue }
          mock_module.backend :solid_queue, options
          mock_module.enqueue_for_backend(SolidQueue, *args)
        end
      end
    end
  end
end
