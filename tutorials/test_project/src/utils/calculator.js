/**
 * Simple Calculator class for basic mathematical operations
 */
class Calculator {
  constructor() {
    this.history = [];
  }

  /**
   * Add two numbers
   * @param {number} a - First number
   * @param {number} b - Second number
   * @returns {number} Sum of a and b
   */
  add(a, b) {
    const result = a + b;
    this.history.push(`${a} + ${b} = ${result}`);
    return result;
  }

  /**
   * Subtract two numbers
   * @param {number} a - First number
   * @param {number} b - Second number
   * @returns {number} Difference of a and b
   */
  subtract(a, b) {
    const result = a - b;
    this.history.push(`${a} - ${b} = ${result}`);
    return result;
  }

  /**
   * Multiply two numbers
   * @param {number} a - First number
   * @param {number} b - Second number
   * @returns {number} Product of a and b
   */
  multiply(a, b) {
    const result = a * b;
    this.history.push(`${a} * ${b} = ${result}`);
    return result;
  }

  /**
   * Divide two numbers
   * @param {number} a - First number
   * @param {number} b - Second number (cannot be zero)
   * @returns {number} Quotient of a and b
   * @throws {Error} If b is zero
   */
  divide(a, b) {
    if (b === 0) {
      throw new Error('Division by zero is not allowed');
    }
    const result = a / b;
    this.history.push(`${a} / ${b} = ${result}`);
    return result;
  }

  /**
   * Get calculation history
   * @returns {Array<string>} Array of calculation strings
   */
  getHistory() {
    return [...this.history];
  }

  /**
   * Clear calculation history
   */
  clearHistory() {
    this.history = [];
  }
}

module.exports = { Calculator }; 