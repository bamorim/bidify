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
    end
  end
end
