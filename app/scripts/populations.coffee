BasicPlant = require 'models/basic-plant'

module.exports = () ->
	venusFlyTrap = new BasicPlant name: "Audrey II"
	console.log "#{venusFlyTrap.name} is for sale at the Little Shop of Horrors"