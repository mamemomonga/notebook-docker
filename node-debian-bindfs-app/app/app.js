'use strict'
import fs from 'fs'

class App {
	constructor() {}
	run() {
		console.log("Hello World!")
		fs.writeFileSync("data/hello.txt","Hello World!\n")
	}
}

new App().run()

