defmodule Node do
    use GenServer

    def start_Link(state) do
        GenServer.start_Link(state)
    end

    def handle_call({:find_successor, search_for_node, hops, message_id, maxNumNodes}, _from, state) do
       #IO.puts "Finding succ of #{search_for_node} from #{state.id}"
       succ_id = state.succ_id
       succ_pid = state.succ_pid
       finger_table = state.finger_table
       [node_id, hops] = cond do
       is_contained?((state.prev_id)+1, search_for_node, state.id, maxNumNodes) ->
           [state.id, hops]
       is_contained?((state.id)+1, search_for_node, succ_id, maxNumNodes) ->
           GenServer.call(succ_pid, {:search_for_message, message_id, hops+1})
       true ->
           {_node_id, node_pid} = closest_preceding_node(Enum.reverse(finger_table), search_for_node, state.id, maxNumNodes)
           #IO.puts "closest_preceding_node of #{search_for_node} in the finger table of #{state.id} is #{node_id}"
           GenServer.call(node_pid, {:find_successor, search_for_node, hops+1, message_id, maxNumNodes})
       end
       {:reply, [node_id, hops], state}
    end



    def init(args) do
        {:ok,args}
    end
end