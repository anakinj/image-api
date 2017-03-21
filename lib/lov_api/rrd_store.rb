module LovApi
  class RRDStore
    RRD_ROOT = File.join(API_ROOT, 'rrd').freeze

    def self.rrd_db_path(name)
      File.join(RRD_ROOT, "#{name}.rrd")
    end

    def initialize(name)
      @name = name.gsub(/[^0-9a-z ]/i, '')
    end

    def put(val, timestamp = Time.now)
      ensure_db
      update(val, timestamp)
    end

    def get(options)
      ensure_db
      parse_rrd_result(fetch(options))
    end

    private

    def parse_rrd_result(res)
      parsed_result = []
      res.split("\n").drop(2).each do |row|
        row_values = row.split(': ')
        next if row_values[1] == 'nan'
        parsed_result << {
          time: DateTime.strptime(row_values[0],'%s').iso8601,
          value: row_values[1].to_f
        }
      end
      parsed_result
    end

    def ensure_db
      FileUtils.mkdir_p(RRD_ROOT)
      create_db unless File.exist?(rrd_file)
    end

    def rrd_file
      self.class.rrd_db_path(@name)
    end

    def update(value, timestamp)
      timestamp = Time.now if timestamp.nil?
      `rrdtool update #{rrd_file} #{timestamp.to_i}:#{value.to_f}`
    end

    def fetch(options)
      options = options.merge(resolution: 300,
                              start: (Time.now.to_i - 600),
                              end: Time.now.to_i,
                              func: 'AVERAGE')

      resolution = options[:resolution].to_i
      start_time = options[:start].to_i
      end_time   = options[:end].to_i
      func       = (options[:func].to_s).gsub(/[^0-9a-z ]/i, '').upcase
      `rrdtool fetch #{rrd_file} #{func} -a -r #{resolution} -s #{start_time} -e #{end_time}`
    end

    def create_db
      command = [
        'rrdtool create',
        rrd_file,
        "--start #{Time.now.to_i - 60*60*24}",
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
