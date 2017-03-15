module LovApi
  class RRDStore
    RRD_ROOT = File.join(API_ROOT, 'rrd').freeze

    def initialize(name)
      @name = name.gsub(/[^0-9a-z ]/i, '')
    end

    def put(val)
      ensure_db
      update(val)
    end

    def get
      ensure_db
      fetch
    end

    private

    def ensure_db
      FileUtils.mkdir_p(RRD_ROOT)
      create_db unless File.exist?(rrd_file)
    end

    def rrd_file
      File.join(RRD_ROOT, "#{@name}.rrd")
    end

    def update(value)
      `rrdtool update #{rrd_file} N:#{value.to_f}`
    end

    def fetch
      `rrdtool fetch #{rrd_file} LAST`.split("\n").drop(2)
    end

    def create_db
      command = [
        'rrdtool create',
        rrd_file,
        '--start N',
        '--step 300',
        'DS:temp:GAUGE:1200:-60:60',

        'RRA:AVERAGE:0.5:1:120',
        'RRA:AVERAGE:0.5:2:120',
        'RRA:AVERAGE:0.5:4:120',
        'RRA:AVERAGE:0.5:10:288',
        'RRA:AVERAGE:0.5:20:1008',
        'RRA:AVERAGE:0.5:60:1440',
        'RRA:AVERAGE:0.5:80:3240',
        'RRA:AVERAGE:0.5:100:5184',
        'RRA:AVERAGE:0.5:120:8760',
        'RRA:AVERAGE:0.5:240:8760',
        'RRA:AVERAGE:0.5:360:8760',

        'RRA:MIN:0.5:1:120',
        'RRA:MIN:0.5:2:120',
        'RRA:MIN:0.5:4:120',
        'RRA:MIN:0.5:10:288',
        'RRA:MIN:0.5:20:1008',
        'RRA:MIN:0.5:60:1440',
        'RRA:MIN:0.5:80:3240',
        'RRA:MIN:0.5:100:5184',
        'RRA:MIN:0.5:120:8760',
        'RRA:MIN:0.5:240:8760',
        'RRA:MIN:0.5:360:8760',

        'RRA:MAX:0.5:1:120',
        'RRA:MAX:0.5:2:120',
        'RRA:MAX:0.5:4:120',
        'RRA:MAX:0.5:10:288',
        'RRA:MAX:0.5:20:1008',
        'RRA:MAX:0.5:60:1440',
        'RRA:MAX:0.5:80:3240',
        'RRA:MAX:0.5:100:5184',
        'RRA:MAX:0.5:120:8760',
        'RRA:MAX:0.5:240:8760',
        'RRA:MAX:0.5:360:8760'
      ].join(' ')
      `#{command}`
    end
  end
end
