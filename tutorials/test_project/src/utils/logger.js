/**
 * Simple Logger class for console output with different log levels
 */
class Logger {
  constructor(level = 'info') {
    this.levels = {
      debug: 0,
      info: 1,
      warn: 2,
      error: 3
    };
    this.level = level;
  }

  /**
   * Check if message should be logged based on current level
   * @param {string} messageLevel - Level of the message
   * @returns {boolean} Whether to log the message
   */
  shouldLog(messageLevel) {
    return this.levels[messageLevel] >= this.levels[this.level];
  }

  /**
   * Format log message with timestamp and level
   * @param {string} level - Log level
   * @param {string} message - Log message
   * @returns {string} Formatted log message
   */
  formatMessage(level, message) {
    const timestamp = new Date().toISOString();
    return `[${timestamp}] ${level.toUpperCase()}: ${message}`;
  }

  /**
   * Log debug message
   * @param {string} message - Message to log
   */
  debug(message) {
    if (this.shouldLog('debug')) {
      console.log(this.formatMessage('debug', message));
    }
  }

  /**
   * Log info message
   * @param {string} message - Message to log
   */
  info(message) {
    if (this.shouldLog('info')) {
      console.log(this.formatMessage('info', message));
    }
  }

  /**
   * Log warning message
   * @param {string} message - Message to log
   */
  warn(message) {
    if (this.shouldLog('warn')) {
      console.warn(this.formatMessage('warn', message));
    }
  }

  /**
   * Log error message
   * @param {string} message - Message to log
   */
  error(message) {
    if (this.shouldLog('error')) {
      console.error(this.formatMessage('error', message));
    }
  }

  /**
   * Set log level
   * @param {string} level - New log level
   */
  setLevel(level) {
    if (this.levels.hasOwnProperty(level)) {
      this.level = level;
    } else {
      throw new Error(`Invalid log level: ${level}`);
    }
  }
}

module.exports = { Logger }; 