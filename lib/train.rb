require './lib/agent'

class Train < Agent
  attr_accessor :name, :id, :table, :stations

  def initialize attributes
    @name = attributes[:name]
    @id = attributes[:id].to_i
    @table = "trains"
    @stations = []
  end

  def assign_to(station)
    DB.exec("INSERT INTO stops (train_id, station_id) VALUES ('#{@id}', '#{station.id}') RETURNING id;")
  end

  def time_at(station)
    db_time = DB.exec("SELECT stops.time FROM stops WHERE train_id = #{self.id} AND station_id = #{station.id};")
    @time = db_time.first['time']
  end

  def set_time attributes
    DB.exec("UPDATE stops SET time = '#{attributes[:time]}' WHERE train_id = #{self.id} AND station_id = #{attributes[:station_id]};")
  end

  def stations
    results = DB.exec("SELECT *
              FROM stations JOIN stops
              ON (stations.id = stops.station_id)
              WHERE (stops.train_id = #{@id})
              ORDER BY (stops.time);")
    results.each do |result|
      name = result['name']
      id = result['station_id']
      time = result['time']
      station = Station.new({:name => name, :id => id, :time => time})
      @stations << station
    end
    @stations
  end

end
