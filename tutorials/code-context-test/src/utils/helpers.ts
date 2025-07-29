// Vector operations for machine learning
export function calculateCosineSimilarity(vectorA: number[], vectorB: number[]): number {
  const dotProduct = vectorA.reduce((sum, a, i) => sum + a * vectorB[i], 0);
  const magnitudeA = Math.sqrt(vectorA.reduce((sum, a) => sum + a * a, 0));
  const magnitudeB = Math.sqrt(vectorB.reduce((sum, b) => sum + b * b, 0));
  
  return dotProduct / (magnitudeA * magnitudeB);
}

// Database connection utilities
export async function connectToDatabase(connectionString: string): Promise<any> {
  // Implementation for database connection
  console.log(`Connecting to database: ${connectionString}`);
  return { connected: true };
}

// String manipulation utilities
export function sanitizeInput(input: string): string {
  return input.replace(/[<>\"']/g, '').trim();
}

// Mathematical operations
export function calculateDistance(point1: [number, number], point2: [number, number]): number {
  const dx = point1[0] - point2[0];
  const dy = point1[1] - point2[1];
  return Math.sqrt(dx * dx + dy * dy);
} 