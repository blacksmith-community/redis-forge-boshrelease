require 'rspec'
require 'yaml'
require 'bosh/template/test'

%w[standalone standalone-6 standalone-7].each do |job_name|
  describe "#{job_name} job templates" do
    let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '..')) }
    let(:job) { release.job(job_name) }
    let(:conf) { job.template('config/redis.conf') }
    let(:bpm) { job.template('config/bpm.yml') }
    let(:store_dir) { "/var/vcap/store/#{job_name}" }
    let(:data_dir) { "/var/vcap/data/#{job_name}" }

    def directives(rendered, name)
      rendered.lines.map(&:strip).select { |l| l.split(/\s+/, 2).first == name }
    end

    def workdir(rendered)
      YAML.safe_load(rendered)['processes'].first['workdir']
    end

    context 'when persistent' do
      let(:props) { { 'auth' => { 'password' => 'x' }, 'persistent' => true } }

      it 'keeps the dataset in the persistent store' do
        expect(directives(conf.render(props), 'dir')).to eq(["dir #{store_dir}"])
      end

      it 'runs redis from the same directory' do
        expect(workdir(bpm.render(props))).to eq(store_dir)
      end

      it 'keeps the AOF on' do
        expect(directives(conf.render(props), 'appendonly')).to eq(['appendonly yes'])
      end

      it 'leaves the default snapshot rules alone' do
        expect(directives(conf.render(props), 'save')).to eq([])
      end
    end

    context 'when not persistent' do
      let(:props) { { 'auth' => { 'password' => 'x' }, 'persistent' => false } }

      it 'points dir at the writable ephemeral data directory' do
        expect(directives(conf.render(props), 'dir')).to eq(["dir #{data_dir}"])
      end

      it 'runs redis from the same directory' do
        expect(workdir(bpm.render(props))).to eq(data_dir)
      end

      it 'turns RDB snapshots off' do
        expect(directives(conf.render(props), 'save')).to eq(['save ""'])
      end

      it 'leaves the AOF off' do
        expect(directives(conf.render(props), 'appendonly')).to eq([])
      end
    end
  end
end
