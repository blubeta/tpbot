// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

window.onload = function (){
  container = document.getElementById("container")

  div = document.createElement("div")
  div.className = "demo-updates mdl-card mdl-shadow--2dp mdl-cell mdl-cell--4-col mdl-cell--4-col-tablet mdl-cell--12-col-desktop"

  spacer = document.createElement("div")
  spacer.className = "demo-separator mdl-cell--1-col"

  container.appendChild(spacer)
  container.appendChild(div)
}
