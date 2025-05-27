module AdminController

using GenieAuthentication, Genie.Renderer, Genie.Exceptions, Genie.Renderer.Html

function index()
  authenticated!()
  h1("Welcome Admin") |> html
end

end
