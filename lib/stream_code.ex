defmodule StreamCode do
  @spec unfold_quoted(acc, (acc -> StreamData.t(val)), (val, acc -> {Macro.t, acc})) ::
        StreamData.t(Macro.t) when acc: var, val: var
  def unfold_quoted(acc, value_fun, next_fun) do
    StreamData.sized(fn
      0 ->
        StreamData.constant(nil)
      size ->
        acc
        |> unfold(value_fun, next_fun, size)
        |> StreamData.map(&{:__block__, [], &1})
    end)
  end

  @spec unfold_string(acc, (acc -> StreamData.t(val)), (val, acc -> {Macro.t, acc})) ::
        String.t when acc: var, val: var
  def unfold_string(acc, value_fun, next_fun) do
    acc
    |> unfold_quoted(value_fun, next_fun)
    |> StreamData.map(&Macro.to_string/1)
  end

  defp unfold(acc, value_fun, next, size) do
    acc
    |> value_fun.()
    |> StreamData.bind(&unfold_next(&1, acc, value_fun, next, size))
  end

  defp unfold_next(value, acc, value_fun, next, size) do
    {quoted, acc} = next.(value, acc)
    acc
    |> unfold_tail(value_fun, next, size-1)
    |> StreamData.map(&[quoted | &1])
  end

  defp unfold_tail(acc, value_fun, next, size) do
    StreamData.frequency([
      {1, StreamData.constant([])},
      {size, unfold(acc, value_fun, next, size)}
    ])
  end
end
