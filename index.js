let express = require("express")
let app = express()
let http = require("http")

let rpio = require("rpio")

// snap-action switches
const LOCKED_SWITCH = 16
const UNLOCKED_SWITCH = 18

// physical button for manually opening/closing
const BUTTON = 15

rpio.open(LOCKED_SWITCH, rpio.INPUT, rpio.PULL_UP)
rpio.open(UNLOCKED_SWITCH, rpio.INPUT, rpio.PULL_UP)

// represents four-pin stepper motor
class Stepper {
	constructor(pins) {
		this.pins = pins

		// timeout for running motor
		this.runTimeout = null

		// open all, set to low
		for(let i = 0; i < 4; i += 1) {
			rpio.open(this.pins[i], rpio.OUTPUT, rpio.LOW)
		}
	}

	// run forward
	run(reverse = false) {
		// halt first
		this.halt()

		// pin counter
		let p = 0;
		// usual stepper motor business
		this.runTimeout = setInterval(() => {
			rpio.write(this.pins[wrapIndex(p-1, 4)], rpio.LOW)
			rpio.write(this.pins[p], rpio.HIGH)
			rpio.write(this.pins[wrapIndex(p+1, 4)], rpio.HIGH)

			if(!reverse) {
				p = wrapIndex(p + 1, 4)
			} else {
				p = wrapIndex(p - 1, 4)
			}

			// Switches are backwards - 1 is open, 0 is pressed

			if(!rpio.read(LOCKED_SWITCH) && !reverse) {
				this.halt()
			}

			if(!rpio.read(UNLOCKED_SWITCH) && reverse) {
				this.halt()
			}

		}, 5) 
	}

	// stops motor and removes resistance (so it can be turned by hand)
	halt() {
		console.log("Stopping.")
		clearInterval(this.runTimeout)

		for(let i = 0; i < 4; i += 1) {
			rpio.write(this.pins[i], rpio.LOW)
		}
	}
}

let server = http.createServer(app).listen(8080, function() {
	console.log("HTTP server listening.");
})

let motor = new Stepper([7,8,10,12])

app.get("/", (req, res) => {
	res.sendFile("index.html")
})

app.get("/open", (req,res) => {
	open()
	res.end()
})

app.get("/close", (req, res) => {
	close()
	res.end()
})

app.get("/forward", (req, res) => {
	motor.run(reverse=false)
	res.end()
})

app.get("/reverse", (req, res) => {
	motor.run(reverse=true)
	res.end()
})

app.get("/halt", (req, res) => {
	motor.halt()
	res.end()
})

// watch for switches
rpio.poll(LOCKED_SWITCH, (pin) => {
	// if door is currently unlocked, pressing the locked trigger manually locks the door
	if(!rpio.read(UNLOCKED_SWITCH)) {
		console.log("Manually locking.")
		close()
	}
})

rpio.poll(UNLOCKED_SWITCH, (pin) => {
	if(!rpio.read(LOCKED_SWITCH)) {
		console.log("Manual unlocking.")
		open()
	}
})

// manual button
rpio.poll(BUTTON, () => {

})

function open() {
	// switch states are reversed - 0 is depressed, 1 is released
	if(rpio.read(UNLOCKED_SWITCH)) {
		console.log("Unlocking...")
		motor.run(reverse=true)
	} else {
		console.log("Already unlocked.")
	}
}

function close() {
	if(rpio.read(LOCKED_SWITCH)) {
		console.log("Locking...")
		motor.run()
	} else {
		console.log("Already locked.")
	}
}

// because JS modulo isn't actually modulo (via Stack Overflow)
function wrapIndex(i, i_max) {
	return ((i % i_max) + i_max) % i_max;
}
