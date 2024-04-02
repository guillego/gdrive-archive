nodes = [
  %{id: "a", parent: nil, extra: "-", children: []},
  %{id: "ab1c1d1", parent: "ab1c1", extra: "-", children: []},
  %{id: "ab3c1d2e3", parent: "ab3c1d2", extra: "-", children: []},
  %{id: "ab1", parent: "a", extra: "-", children: []},
  %{id: "ab3c1", parent: "ab3", extra: "-", children: []},
  %{id: "ab2c2d2", parent: "ab2c2", extra: "-", children: []},
  %{id: "ab2c2d3", parent: "ab2c2", extra: "-", children: []},
  %{id: "ab2c1d2e4", parent: "ab2c1d2", extra: "-", children: []},
  %{id: "ab2", parent: "a", extra: "-", children: []},
  %{id: "ab1c1", parent: "ab1", extra: "-", children: []},
  %{id: "ab3c1d2", parent: "ab3c1", extra: "-", children: []},
  %{id: "ab3", parent: "a", extra: "-", children: []},
  %{id: "ab2c2", parent: "ab2", extra: "-", children: []},
  %{id: "ab2c1d2", parent: "ab2c1", extra: "-", children: []},
  %{id: "ab4", parent: "a", extra: "-", children: []},
  %{id: "ab2c1d2e4f1", parent: "ab2c1d2e4", extra: "-", children: []},
  %{id: "ab2c1", parent: "ab2", extra: "-", children: []},
]


def tree_builder(nodes) do
# First pass, get all the roots, that is, parent is nil
tree = get_children(nodes, nil)

# Recursive pass, go through each tree level and collect the children from the nodes
# Basically I need to do this recursively for all levels of the tree, here I'm only doing it
# For the top level, how do I go down the tree as I add more children?
tree =
tree
|> Enum.map(fn x -> Map.put(x, :children, get_children(nodes, x.id)) end)

end


defp get_children(nodes, parent_id) do
  nodes
  |> Enum.filter(fn x -> x.parent == parent_id end)
end
