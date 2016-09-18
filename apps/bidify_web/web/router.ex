defmodule Bidify.Web.Router do
  use Bidify.Web.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Bidify.Web do
    pipe_through [:browser, :browser_auth] # Use the default browser stack

    get "/", AuctionsController, :index

    resources "/registrations", RegistrationController, only: [:new, :create]
    get "/login", SessionController, :new
    post "/login", SessionController, :create
    get "/logout", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", Bidify.Web do
  #   pipe_through :api
  # end
end
