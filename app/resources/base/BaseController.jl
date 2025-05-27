module BaseController

using Genie.Renderer.Html, SearchLight

function index()
  html(:base, :image)
end
    
end