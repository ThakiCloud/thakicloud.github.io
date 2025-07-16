const { Calculator } = require('./utils/calculator');
const { Logger } = require('./utils/logger');

class App {
  constructor() {
    this.calculator = new Calculator();
    this.logger = new Logger();
  }

  run() {
    this.logger.info('Starting Shotgun Test Application');
    
    const result1 = this.calculator.add(5, 3);
    this.logger.info(`Addition: 5 + 3 = ${result1}`);
    
    const result2 = this.calculator.multiply(4, 7);
    this.logger.info(`Multiplication: 4 * 7 = ${result2}`);
    
    this.logger.info('Application finished successfully');
  }
}

// Entry point
const app = new App();
app.run(); 