require 'rspec'
require 'json'
require 'yaml'
require 'bosh/template/test'

# The broker refuses a parameter the plan's schema doesn't declare, so
# the schema has to name every meta.params key the plan manifests read.
describe 'redis-blacksmith-plans parameter schema' do
  let(:root) { File.join(File.dirname(__FILE__), '..') }
  let(:job_dir) { File.join(root, 'jobs', 'redis-blacksmith-plans') }
  let(:plans_dir) { File.join(job_dir, 'templates', 'plans') }
  let(:schemas) do
    Dir.glob(File.join(plans_dir, 'schema-*.json')).map { |f| [File.basename(f), JSON.parse(File.read(f))] }.to_h
  end
  let(:schema) { schemas.fetch('schema-7.json') }
  let(:read_keys) do
    Dir.glob(File.join(job_dir, 'templates', 'plans', '*', 'manifest.yml'))
       .flat_map { |file| File.read(file).scan(/meta\.params\.([A-Za-z0-9_-]+)/).flatten }
       .uniq.sort
  end

  it 'names draft-04 and declares every meta.params key the manifests read' do
    expect(read_keys).not_to be_empty
    expect(schemas.keys.sort).to eq(%w[schema-5.json schema-6.json schema-7.json])
    schemas.each_value do |each|
      expect(each['$schema']).to eq('http://json-schema.org/draft-04/schema#')
      expect(each['properties'].keys.sort).to eq(read_keys)
    end
  end

  # The notify-keyspace-events flags each packaged Redis accepts, from
  # keyspaceEventsStringToFlags in that version's src/notify.c.
  flags_by_package = {
    'redis'   => { schema: 'schema-5.json', flags: 'Ag$lshzxeKEt' },   # redis 5.0.14
    'redis-6' => { schema: 'schema-6.json', flags: 'Ag$lshzxeKEtmd' }, # redis 6.2.21
    'redis-7' => { schema: 'schema-7.json', flags: 'Ag$lshzxeKEtmdn' } # redis 7.2.12
  }

  %w[standalone cluster standalone-6 cluster-6 standalone-7 cluster-7].each do |type|
    it "gives plan type #{type} the flag set of the Redis it runs" do
      package = YAML.safe_load(File.read(File.join(root, 'jobs', type, 'spec')))['packages'].find { |n| n.start_with?('redis') }
      expected = flags_by_package.fetch(package)

      script = Bosh::Template::Test::ReleaseDir.new(root).job('redis-blacksmith-plans')
        .template('bin/configure-blacksmith')
        .render({ 'environment' => 'lab', 'plans' => { 'one' => { 'type' => type, 'masters' => 3 } } })
      expect(script.scan(/schema[-0-9]*\.json/).uniq).to eq([expected[:schema], 'schema.json'].sort_by { |n| n == 'schema.json' ? 1 : 0 })

      pattern = schemas.fetch(expected[:schema])['properties']['notify-keyspace-events']['pattern']
      accepted = pattern[/\[(.*)\]/, 1].chars.sort
      expect(accepted).to eq(expected[:flags].chars.sort)
    end
  end

  it 'does not open the schema to undeclared keys' do
    expect(schema).not_to have_key('additionalProperties')
  end

  it 'ships schema.json with the job and copies it into each plan' do
    spec = File.read(File.join(job_dir, 'spec'))
    %w[schema-5 schema-6 schema-7].each { |n| expect(spec).to include("plans/#{n}.json") }

    script = Bosh::Template::Test::ReleaseDir.new(root).job('redis-blacksmith-plans')
      .template('bin/configure-blacksmith')
      .render({ 'environment' => 'lab', 'plans' => { 'one' => { 'type' => 'standalone' }, 'two' => { 'type' => 'cluster', 'masters' => 3 } } })
    expect(script.scan('schema-5.json').length).to be >= 1
    expect(script.scan('schema-7.json')).to be_empty
  end
end
