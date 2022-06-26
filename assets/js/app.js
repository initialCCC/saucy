// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

import "phoenix_html"

// import "./user_socket.js"
import socket from "./user_socket.js"

window.socket = socket
// let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// let liveSocket = new LiveSocket("/", Socket, {params: {_csrf_token: csrfToken}})

// liveSocket.connect()

// window.liveSocket = liveSocket

