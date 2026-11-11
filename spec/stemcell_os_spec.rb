require 'rspec'
require 'yaml'
require 'bosh/template/test'

# The kit passes stemcell_os and stemcell_version to the forge job. A
# deployment that sets neither must keep rendering the stemcell block the
# plans have always rendered.
describe 'redis-blacksmith-plans stemcell block' do
  let(:root) { File.join(File.dirname(__FILE__), '..') }
  let(:release) { Bosh::Template::Test::ReleaseDir.new(root) }
  let(:job) { release.job('redis-blacksmith-plans') }
  let(:base_props) do
    {
      'environment' => 'lab',
      'bosh_env' => 'lab',
      'service' => { 'type' => 'standalone' },
      'redis' => { 'tls' => { 'enabled' => true, 'dual-mode' => false } }
    }
  end

  def stemcell(plan, props)
    rendered = job.template("plans/#{plan}/manifest.yml").render(props)
    YAML.safe_load(rendered)['stemcells']
  end

  plans = %w[standalone standalone-6 standalone-7 cluster cluster-6 cluster-7]

  plans.each do |plan|
    context "plan #{plan}" do
      it 'renders ubuntu-jammy and latest when nothing is set' do
        expect(stemcell(plan, base_props)).to eq([{ 'alias' => 'default', 'os' => 'ubuntu-jammy', 'version' => 'latest' }])
      end

      it 'renders noble when stemcell_os is ubuntu-noble' do
        sc = stemcell(plan, base_props.merge('stemcell_os' => 'ubuntu-noble'))
        expect(sc.first['os']).to eq('ubuntu-noble')
        expect(sc.first['version']).to eq('latest')
      end

      it 'takes the version from stemcell_version' do
        sc = stemcell(plan, base_props.merge('stemcell_os' => 'ubuntu-noble', 'stemcell_version' => '1.250'))
        expect(sc.first['version']).to eq('1.250')
      end
    end
  end

  %w[standalone-6 standalone-7].each do |plan|
    it "keeps #{plan} on service.stemcell when stemcell_version is unset" do
      props = base_props.merge('service' => { 'type' => 'standalone', 'stemcell' => '1.100' })
      expect(stemcell(plan, props).first['version']).to eq('1.100')
    end

    it "prefers stemcell_version over service.stemcell in #{plan}" do
      props = base_props.merge('service' => { 'type' => 'standalone', 'stemcell' => '1.100' }, 'stemcell_version' => '1.250')
      expect(stemcell(plan, props).first['version']).to eq('1.250')
    end
  end
end
