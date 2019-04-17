defmodule Toby.Util.Tree do
  @moduledoc """
  Functions for working with abstract trees (but particularly
  process/supervision trees).
  """

  @doc """
  Given a tree data structure (`{label, children}`), this produces a copy of the
  tree with the index of each node (as visited in a depth-first traversal)
  included (`{{label, index}, children}`).

  Visually, it takes something like this:

      A
      └── B
          └── C
              ├── D
              └── E

  And produces this:

      (A, 1)
      └── (B, 2)
          └── (C, 3)
              ├── (D, 4)
              └── (E, 5)

  (If `A` had a sibling, it would start at 6.)

  For example, this is useful when mapping a tree to rows in a user interface,
  and allows a cursor to map to a particular node of the tree.
  """
  def to_indexed_tree({name, children}, start_idx \\ 0) do
    {indexed_children, last_idx} =
      Enum.map_reduce(children, start_idx + 1, fn node, idx ->
        to_indexed_tree(node, idx)
      end)

    node = {{name, start_idx}, indexed_children}

    {node, last_idx}
  end

  @doc """
  Given a tree with indexes in the structure returned by `to_indexed_tree/2`,
  this function returns the node at a particular index.
  """
  def node_at({{_name, idx}, _children} = node, idx) do
    node
  end

  def node_at({{name, other_idx}, [child | rest]}, idx) do
    node_at(child, idx) || node_at({{name, other_idx}, rest}, idx)
  end

  def node_at({{_name, _other_idx}, []}, _idx) do
    nil
  end
end
