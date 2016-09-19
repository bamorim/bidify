defmodule Bidify.Web.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Bidify.Web.Web, :controller
      use Bidify.Web.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: Bidify.Web

      alias Bidify.Web.Repo
      import Ecto
      import Ecto.Query

      import Bidify.Web.Router.Helpers
      import Bidify.Web.Gettext

      import Bidify.Web.Session, only: [current_user: 1, logged_in?: 1]
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates", namespace: Bidify.Web

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Bidify.Web.Router.Helpers
      import Bidify.Web.ErrorHelpers
      import Bidify.Web.Gettext

      import Bidify.Web.Session, only: [current_user: 1, logged_in?: 1]
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias Bidify.Web.Repo
      import Ecto
      import Ecto.Query
      import Bidify.Web.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
