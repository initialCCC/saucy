import {Socket} from "phoenix"

let socket = new Socket("/socket", {})

socket.connect()

let channel = socket.channel("room:lobby", {})
let copyButton  = document.getElementById("copy")
let inputArea   = document.getElementById("input")
let outputArea  = document.getElementById("output") 
let scssButton  = document.getElementById("from-scss")
let sassButton  = document.getElementById("from-sass")
let clearButton = document.getElementById("clear-all")

const handleScss = (_event) => {
  channel.push("convert", {format: "scss", body: inputArea.value.trim()})
}

const handleSass = (_event) => {
  channel.push("convert", {format: "sass", body: inputArea.value.trim()})
}

const handleClear = (_event) => {
  inputArea.value = ''
  outputArea.value = ''
}

const handlePlaceHolder = () => {
  console.log("clearing place holder")
}

const handleCopy = (_event) => {
  navigator.clipboard.writeText(outputArea.value)
}

const handleConverted = (payload) => {
  if (payload.body) {
    outputArea.value = payload.body
  } else {
    outputArea.value = ''
    outputArea.placeholder = 'invalid input...'
    setTimeout(handlePlaceHolder, 1500)
    console.log("failed converting")
  }
}

const scream = () => {
  console.log("SCREAAAAMING")
}

setTimeout(scream, 1000);

clearTimeout()

channel.on("converted", handleConverted)
scssButton.addEventListener("click", handleScss)
sassButton.addEventListener("click", handleSass)
copyButton.addEventListener("click", handleCopy)
clearButton.addEventListener("click", handleClear)

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp)})
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket