# Software patch-panel.
class PatchPanel < Trema::Controller
  def start(_args)
    @patches = Hash.new( [] )
    @mirrors = Hash.new( [] )
    logger.info 'PatchPanel started.'
  end

  def switch_ready(dpid)
    @patches[dpid].each do |port_a, port_b|
      delete_flow_entries dpid, port_a, port_b
      add_flow_entries dpid, port_a, port_b
    end
  end

  def create_patch(dpid, port_a, port_b)
    add_flow_entries dpid, port_a, port_b
    @patches[dpid].push( [port_a, port_b].sort )
  end

  def delete_patch(dpid, port_a, port_b)
    delete_flow_entries dpid, port_a, port_b
    @patches[dpid].delete( [port_a, port_b].sort )
  end

  def create_mirror(dpid, port_a, port_b)
    add_mirror_entry dpid, port_a, port_b
    @mirrors[dpid].push( [port_a, port_b] )
  end
  
  def delete_mirror(dpid, port_a, port_b)
    if @mirrors[dpid].include?([port_a, port_b]) then
      delete_mirror_entry dpid, port_a, port_b
      @mirrors[dpid].delete( [port_a, port_b] )
    else
      return "[#{port_a.to_s}, #{port_b.to_s}] does NOT exist in Mirrors."
    end
  end
  
  def dump(dpid)
    #Extract all patches
    str = "Patches:\n"
    for patch in @patches[dpid].each do
      port_in = patch[0]
      port_out = patch[1]
      str += "\t"
      str += port_in.to_s
      str += "<->"
      str += port_out.to_s
      str += "\n"
    end
    #Extract all mirrors
    str += "Mirrors:\n"
    for mirror in @mirrors[dpid].each do
      port_monitor = mirror[0]
      port_mirror = mirror[1]
      str += "\t"
      str += port_monitor.to_s
      str += "->"
      str += port_mirror.to_s
      str += "\n"
    end
    str
  end

  private

  def add_flow_entries(dpid, port_a, port_b)
    send_flow_mod_add(dpid,
                      match: Match.new(in_port: port_a),
                      actions: SendOutPort.new(port_b))
    send_flow_mod_add(dpid,
                      match: Match.new(in_port: port_b),
                      actions: SendOutPort.new(port_a))
  end

  def delete_flow_entries(dpid, port_a, port_b)
    send_flow_mod_delete(dpid, match: Match.new(in_port: port_a))
    send_flow_mod_delete(dpid, match: Match.new(in_port: port_b))
  end

  def add_mirror_entry(dpid, port_monitor, port_mirror)
    #Delete flows from port_monitor
    send_flow_mod_delete(dpid, match: Match.new(in_port: port_monitor))
    #Extract patches belonging port_monitor.
    for patch in @patches[dpid].each do
      port_in = patch[0]
      port_out = patch[1]
      if port_in == port_monitor then
        send_flow_mod_delete(dpid, match: Match.new(in_port: port_in))
        send_flow_mod_add(dpid,
                      match: Match.new(in_port: port_monitor),
                      actions: [
                        SendOutPort.new(port_out),
                        SendOutPort.new(port_mirror)
                      ])
      end
    end
  end
  
  def delete_mirror_entry(dpid, port_monitor, port_mirror)
    #Delete flows from port_monitor
    send_flow_mod_delete(dpid, match: Match.new(in_port: port_monitor))
    #Extract patches belonging port_monitor.
    for patch in @patches[dpid].each do
      port_in = patch[0]
      port_out = patch[1]
      #Re-connect patches for port_in
      if port_in == port_monitor then
        send_flow_mod_add(dpid,
                      match: Match.new(in_port: port_in),
                      actions: SendOutPort.new(port_out))
      end
    end
  end
end
