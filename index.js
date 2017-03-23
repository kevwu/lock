let express = require("express")
let app = express()
let http = require("http")

let rpio = require("rpio")

const LOCKED_SWITCH = 5
const UNLOCKED_SWITCH = 6

rpio.open(LOCKED_SWITCH, rpio.INPUT)
rpio.open(UNLOCKED_SWITCH, rpio.INPUT)

let server = http.createServer(app).listen(8080, function() {
	console.log("HTTP server listening.");
})

let motor = new Stepper([1,2,3,4])

app.get("/", (req, res) => {
	res.sendFile("index.html")
})

app.get("/open", (req,res) => {
	if(!rpio.read(UNLOCKED_SWITCH)) {
		console.log("Unlocking...")
		motor.run()
	} else {
		console.log("Already unlocked.")
	}
})

app.get("/close", (req, res) => {
	if(!rpio.read(LOCKED_SWITCH)) {
		console.log("Locking...")
		motor.run(reverse=true)
	} else {
		console.log("Already locked.")
	}
})

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
		// pin counter
		let p = 0;
		// usual stepper motor business
		this.runTimeout = setInterval(() => {
			console.log("Stepping " + p +"," +  wrapIndex(p+1, 4))
			rpio.write(this.pins[p], rpio.HIGH)
			rpio.write(this.pins[(p+1) % 4], rpio.HIGH)

			if(!reverse) {
				p = wrapIndex(p + 1, 4)
			} else {
				p = wrapIndex(p - 1, 4)
			}
		}, 100)
	}

	// stops motor and removes resistance (so it can be turned by hand)
	halt() {
		console.log("Halting")
		clearInterval(this.runTimeout)

		for(let i = 0; i < 4; i += 1) {
			rpio.write(this.pins[i], rpio.LOW)
		}
	}
}

// because JS modulo isn't actually modulo (via Stack Overflow)
function wrapIndex(i, i_max) {
	return ((i % i_max) + i_max) % i_max;
}