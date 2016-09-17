defmodule Bidify.Shared.InMemoryEntityRepository do
  defmacro __using__(opts=[]) do
    quote do
      def start_link do
        Agent.start_link(fn -> %{} end, name: __MODULE__)
      end

      def find(id) do
        {:ok, Agent.get(__MODULE__, &(Map.get(&1, id)))}
      end

      def save(entity) do
        Agent.update(__MODULE__, &(Map.put(&1, entity.id, entity)))
        :ok
      end

      def create(entity) do
        Agent.get_and_update(__MODULE__, fn map ->
          id = case map |> Map.keys do
                 [] -> 1
                 ids -> Enum.max(ids) + 1
               end
          entity = %{entity | id: id}
          {{:ok, entity}, Map.put(map, entity.id, entity)}
        end)
      end

      def rollback do
        raise :rollback
      end

      def transaction(fun) do
        Agent.update(__MODULE__, fn map ->
          map |> Map.put(:__dirty__, map)
        end)

        result =
          try do
            fun.()
          rescue
            _ ->
              Agent.update(__MODULE__, &(Map.get(&1, :__dirty__)))
              {:error, :rollback}
          end

        Agent.update(__MODULE__, fn map ->
          map |> Map.delete(:__dirty__)
        end)

        result
      end
    end
  end
end
