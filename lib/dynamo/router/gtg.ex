# This module is responsible for handling generalized graphs.
# Those graphs are list of tuples where the first element
# of the tuple is an identifier and the second one is another
# list of tuples.
defmodule Dynamo::Router::GTG do
  # Receives a tree produced by Dynamo::Router::Parser
  # and converts it to a branch of a generalized
  # transition graph.
  def branch(ast, endpoint) do
    visit(ast, endpoint)
  end

  # Merge a list of branches given as left and the
  # branch given as right.
  def merge(left, right) do
    merge(left, right, [])
  end

  ## Helpers related to branch visiting

  defp visit({ :cat, left, right }, endpoint) do
    left  = terminal(left)
    right = visit(right, endpoint)
    { left, [right] }
  end

  defp visit(tuple, endpoint) do
    { terminal(tuple), [{ :endpoint, endpoint }] }
  end

  defp terminal({ :terminal, contents }) do
    contents
  end

  ## Helpers related to merging visiting

  # If the two items are equal, jackpot! We should merge old
  # with new and then rewind acc on top of the tail.
  defp merge([{ left, old }|t], { left, new }, acc) do
    merged = merge_each(left, old, new, acc)
    Enum.foldl merged, t, fn(x, acc) { [x|acc] }
  end

  # If not equal, keep searching.
  defp merge([h|t], tuple, acc) do
    merge(t, tuple, [h|acc])
  end

  # If we reached the end of the list, add the tuple at
  # the end and reverse.
  defp merge([], tuple, acc) do
    List.reverse [tuple|acc]
  end

  # Handle merge_each for endpoints where old and new are not lists.
  defp merge_each(:endpoint, old, new, acc) do
    [{ :endpoint, new }, { :endpoint, old }|acc]
  end

  # Merge each item when old/new are lists.
  defp merge_each(left, old, new, acc) do
    merged = Enum.foldl new, old, fn(x, acc) { merge(acc, x, []) }
    [{ left, merged }|acc]
  end
end