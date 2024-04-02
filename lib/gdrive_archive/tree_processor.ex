defmodule GdriveArchive.TreeProcessor do
  def build_tree(nodes) do
    get_children(nodes, nil)
  end

  defp get_children(nodes, parent_id) do
    nodes
    |> Enum.filter(fn x -> x.parent == parent_id end)
    |> Enum.map(fn node ->
      children = get_children(nodes, node.id)
      Map.put(node, :children, children)
    end)
  end

end
