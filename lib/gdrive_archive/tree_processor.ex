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

  def compute_tree_size(tree) do
    tree
    |> Enum.map(fn root -> process_node_size(root) end)
  end

  defp process_node_size(%{children: []} = node) do
    node
    |> Map.put_new(:children_size, 0)
  end

  defp process_node_size(%{children: children} = node) when is_list(children) do
    # Recursively process all children of this node
    children_with_size =
      children
      |> Enum.map(&process_node_size/1)

    # Add up all of the sizes of the direct children of this node
    children_size =
      Enum.reduce(children_with_size, 0, fn child, acc ->
        acc + (child.size || 0) + (child.children_size || 0)
      end)

    node
    |> Map.put(:children_size, children_size)
    |> Map.put(:children, children_with_size)
  end

  defp process_node_size(node), do: node
end
