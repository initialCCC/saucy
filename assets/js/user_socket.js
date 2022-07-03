import {Socket} from "phoenix"

let socket = new Socket("/socket", {})

socket.connect()

let channel = socket.channel("room:lobby", {})
let copyButton   = document.getElementById("copy")
let inputArea    = document.getElementById("input")
let outputArea   = document.getElementById("output") 
let scssButton   = document.getElementById("from-scss")
let sassButton   = document.getElementById("from-sass")
let clearButton  = document.getElementById("clear-all")
let importInput = document.getElementById("import-file")

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

const handleCopy = (_event) => {
  navigator.clipboard.writeText(outputArea.value)
}

const handleConverted = (payload) => {
  if (payload.body) {
    outputArea.style.color = 'black'
    outputArea.value = payload.body
  } else {
    outputArea.style.color = 'red'
    outputArea.value = 'invalid input'
  }
}

// https://plnkr.co/edit/DbBfnc6XaMppCvkEoqql?p=preview&preview
const handleFileSelect = (event) => {
  const reader = new FileReader()
  reader.onload = handleFileUpload
  reader.readAsText(event.target.files[0])
}

const handleFileUpload = (event) => {
  inputArea.value = event.target.result;
}

channel.on("converted", handleConverted)
scssButton.addEventListener("click", handleScss)
sassButton.addEventListener("click", handleSass)
copyButton.addEventListener("click", handleCopy)
clearButton.addEventListener("click", handleClear)
importInput.addEventListener("change", handleFileSelect)

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp)})
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket