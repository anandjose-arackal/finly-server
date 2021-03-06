class Docs::P2P::Inwards::Received::Action < ActionManager::API
  action :export,
         :export,
         label: "Export",
         icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
         route: "received.index"
end